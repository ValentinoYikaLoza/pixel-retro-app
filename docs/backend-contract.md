# Contrato de Backend (derivado del frontend)

> **El frontend es la fuente de verdad.** Este documento define qué debe
> enviar/recibir cada endpoint REST y cada canal de WebSocket, en función de lo
> que las vistas realmente consumen. El backend se implementa **a partir de
> esto**, no al revés.

---

## 0. Convenciones

- **Envelope REST** (todas las respuestas):
  ```jsonc
  { "success": boolean, "message": string, "data": <payload> }
  ```
- **Errores**: status HTTP no-2xx con `{ "message": string }`. El front lo mapea
  a `ServiceException` ([error_service.dart](../lib/app/shared/services/error_service.dart)).
- **IDs**: enteros estables. Todo recurso incluye `id` (identidad/-key de lista),
  aunque no siempre se muestre.
- **Textos de presentación**: el backend **no** arma cadenas visibles salvo
  contenido editorial (p. ej. la descripción de una misión). Valores
  numéricos/estructurados los arma el front (i18n, formato).
- **Fechas**: ISO-8601 en UTC (`2026-05-23T20:00:00Z`).

---

## 1. Decisiones de optimización (resumen)

| # | Decisión | Efecto |
|---|----------|--------|
| 1 | **WebSocket = fuente de verdad de la data en vivo** (stats, ranking, misiones): snapshot al suscribirse **+** deltas. | `getUser`, `listUsers`, `listMissions` dejan de ser necesarios para *leer*. REST queda para **acciones** y un **bootstrap** opcional. |
| 2 | **`/getTime` = un solo timestamp.** El cliente deriva mes y las 4 cuentas regresivas. | NO crear endpoints de "tiempo restante" ni "mes actual". |
| 3 | **Leaderboard: divisiones cacheadas + ranking aparte** (NO fusionar). Divisiones casi estáticas = 1 fetch/sesión; usuarios en vivo. | Fusionarlos re-enviaría las divisiones en cada entrada; con caché el 2º request es gratis. |
| 4 | **Anuncios sin prosa**: enviar `reward` + `rewardType`; el texto lo arma el front. ✅ implementado | Menos over-fetch, i18n correcta. |
| 5 | **Imagen de items por `id` estable, no por índice.** ✅ implementado | El índice es frágil (reordenar la rompe); el `id` no. |
| 6 | **Paginación del ranking**: `limit` (+ `cursor` opcional) en REST **y** ventana en el push del socket. | Evita traer/empujar el ranking completo. |

---

## 2. Endpoints REST

### 2.1 `GET /getTime`  — **necesario**
Único origen de tiempo; el cliente deriva todo lo demás.
```jsonc
// req: (sin body)
// res 200:
{ "success": true, "message": "", "data": { "time": "2026-05-23T20:00:00Z" } }
```

### 2.2 `GET /listGames`  — **necesario** (catálogo, cacheable)
`code` es la clave estable (el cliente la usa para asset/ruta: `assets/images/{code}.png`, `/level-{code}-game`). NO enviar rutas ni nombres de asset.
```jsonc
// res 200:
{ "success": true, "message": "", "data": [
  { "id": 1, "code": "snake", "title": "Snake", "enabled": true }
] }
```
> `enabled` permite activar/desactivar juegos desde el server (valor de tener
> esto en backend en vez de hardcodear en el cliente).

### 2.3 Leaderboard — **2 endpoints separados** (divisiones cacheadas, ranking en vivo)
Se mantienen separados a propósito: las **divisiones son casi estáticas** (el
front las cachea 1 vez/sesión) y el **ranking es en vivo**; fusionarlos
re-enviaría las divisiones en cada entrada.
```jsonc
GET /listDivisions          // cacheable en el cliente
// data: [ { "id": 1, "name": "Bronce" } ]

POST /listUsers  { "userId": "1", "limit": 50 }   // o vía socket (ver §3.3)
// data: { "userList": [
//   { "id": 7, "name": "Ana", "score": 1200, "timesRankedFirst": 3, "flag": "🇵🇪" }
// ] }
```
> `flag` ya como emoji/string mostrable. El ranking llega **ordenado** por score.
> `limit` acota el payload (paginación). `timesRankedFirst` es secundario: si la
> fila del ranking se simplifica (ver §4), puede moverse a un detalle/perfil.

### 2.4 Acciones (mutaciones)  — **necesarias** (no se pueden mover al socket)
Devuelven solo `success`/`message`; el estado actualizado llega por el canal de
stats del socket (evita doble fuente).
```jsonc
POST /updateCoins   { "userId": "1", "coins": 50 }
POST /updateLives   { "userId": "1", "lives": 3 }
POST /updateStreak  { "userId": "1" }
POST /updateExp     { "userId": "1", "exp": 120 }
POST /updateProgress{ "userId": "1", "rewardId": "2", "currentPoints": 5 }

POST /purchaseCoinShopItem { "userId": "1", "itemId": 3 }
POST /purchaseLiveShopItem { "userId": "1", "itemId": 3 }
POST /claimAdvertisement   { "userId": "1", "advertisementId": 2 }
// res 200 (todas): { "success": true, "message": "..." , "data": null }
```

### 2.5 Catálogos de tienda  — **necesarios** (cacheables)
```jsonc
GET /listCoinShop
// data: [ { "id": 1, "quantity": 100, "price": 1.99 } ]

GET /listLiveShop
// data: [ { "id": 1, "quantity": 5, "price": 1.99, "typeId": 1 } ]   // typeId 1=usd, 2=coin

POST /listAdvertisements  { "userId": "1" }
// data: [ { "id": 1, "reward": 10, "rewardType": "coin", "isClaimed": false } ]
```
> **Imagen por `id` estable** (el cliente mapea `id → asset`), no por índice de
> lista. En anuncios: `rewardType ∈ {coin, life}` y **NO enviar `description`**;
> el front arma "Mira un anuncio y gana 10 monedas" desde `reward` + `rewardType`.

### 2.6 (Opcional) `GET /bootstrap`
Si se quiere primer pintado en una sola llamada en vez de N por pantalla:
`{ user, time, leaderboard, missions, shop }`. Trade-off vs. carga perezosa por
pantalla (hoy el front carga por pantalla).

---

## 3. Canales WebSocket (Pusher-style)

Suscripción al conectar: `user.stats.{userId}`, `user.missions.{userId}`,
`user.users.{userId}`. **Cada canal debe emitir un snapshot al suscribirse** y
luego deltas. Así estos datos NO necesitan endpoint REST de lectura.

### 3.1 `StatsUpdated` (canal `user.stats.{userId}`) — fuente de `coins/lives/streak/division`
```jsonc
{ "user": { "id": 7, "coins": 120, "lives": 3, "streak": 9, "divisionId": 2 } }
```
> Reemplaza a `GET /getUser`. La appbar y el leaderboard (división actual) leen de aquí.

### 3.2 `MissionsUpdated` (canal `user.missions.{userId}`) — fuente de misiones
```jsonc
{ "missions": {
  "dailyMissions":   [ { "id": 1, "description": "Gana 1 partida", "rewardId": 1, "statusId": 1, "currentValue": 0, "totalValue": 1 } ],
  "weeklyMissions":  [ /* idem */ ],
  "monthlyMissions": [ /* idem */ ]
} }
```
> Reemplaza a `POST /listMissions`. `rewardId → cofre (bronce/plata/oro)`,
> `statusId → reclamado/no`. La vista hoy usa `description/currentValue/totalValue/rewardId`;
> `statusId`/`id` se mantienen para el **reclamo** (feature pendiente).

### 3.3 `UsersUpdated` (canal `user.users.{userId}`) — ranking en vivo
```jsonc
{ "users": { "userList": [
  { "id": 7, "name": "Ana", "score": 1200, "timesRankedFirst": 3, "flag": "🇵🇪" }
] } }
```
> Para que la paginación funcione de verdad, este push debería respetar la
> **misma ventana** que el REST (`limit`), no empujar el ranking completo.

---

## 4. Over-fetching / hallazgos por vista

| Recurso | La vista usa | Se recibe de más | Acción |
|---------|--------------|------------------|--------|
| **Game** | `code`, `title` | `id` (no se muestra) | Mantener `id` (identidad). Quitar nombre/rutas de asset del server. |
| **Mission** | `description`, `currentValue`, `totalValue`, `rewardId` | `id`, `statusId` no se renderizan | Mantener (necesarios para reclamar). |
| **Advertisement** | `description`, `typeId` | `reward`, `isClaimed` no se usan; `description` es prosa | Enviar `reward`+`rewardType`, **quitar `description`**; el front arma el texto. |
| **CoinShop / LiveShop** | `quantity`, `price`(+`rewardType`) | `id` no se usa; **imagen por índice** | Enviar `code` para la imagen; usar `id` como key. |
| **User stats** | `coins`, `lives`, `streak`, `divisionId`, `id` | — | Correcto. Solo por socket (no REST). |
| **Time** | `currentDate` | — | Correcto. Un timestamp; el resto se deriva. |

**Fuentes cruzadas correctas** (no tocar): la división actual y el resaltado del
usuario en el leaderboard salen de **stats** (no del endpoint de leaderboard); el
mes y las cuentas regresivas salen de **time** (no de misiones).

---

## 5. Mapa "vista → fuente" (final recomendado)

| Vista | Fuente(s) | Requests |
|-------|-----------|----------|
| Splash | — | ninguno (solo navega) |
| Home | `GET /listGames` (cache) | 1 |
| Appbar (global) | socket `StatsUpdated` | 0 REST |
| Leaderboard | `GET /leaderboard` (cache divisiones) + socket `UsersUpdated` | 1 |
| Misiones | socket `MissionsUpdated` + `GET /getTime` (compartido) | 0–1 |
| Tienda | `GET /listCoinShop`,`/listLiveShop` (cache) + anuncios | 2–3 |
| Juego | local | 0 |

> Con el socket como fuente de verdad de lo vivo, el arranque típico baja de
> ~8 requests REST a ~3–4 (todos cacheables), más los canales del socket.
