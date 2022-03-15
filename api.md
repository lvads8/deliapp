# LogiNext Driver API

- Base URL: `https://products.loginextsolutions.com`
- Headers:
    - Host products.loginextsolutions.com
    - x-app-version (5.0.99)
    - x-platform iOS/Android
    - user-agent LogiNextApps
    - Content-Type application/json; charset=utf-8

# `POST /LoginApp/login/mobile/authenticate`

## Request

### Body

```json
{
    "userName": "<username>",
    "password": "128:<salt>:<hash>",
    "imei": ""
}
```

*** *How to "generate" the password?***

1. `salt = username.trim().toLowerCase() + password + "MOBILE"`
2. `key = PBEKeySpec(passwordBytes, saltBytes, 128, 512)`
3. `cipher = SecretKeyFactory("PBKDF2WithHmacSHA1").generateSecret(key))`
4. `hash = cipher.getEncoded()`

## Response

### Code

- 200: OK
- 401: Bad username or password

### Headers

- www-authenticate
- client_secret_key

### Body

```json
{
    "status": 200,
    "data": {
        "deliveryMediumName": "<driver name>"
    }
}
```

# `POST /LoginApp/login/mobile/logout`

## Request

### Headers

- client_secret_key
- www-authenticate

### Body

```json
{}
```

## Response

### Code

- 200: OK
- 401: Already logged out

# `GET ShipmentApp/mobile/shipment/orders/COMPLETED/v2?version=466&paramkey=com.loginext.tracknext`

## Request

### Headers

- client_secret_key
- www-authenticate

### Body

```json
{}
```

## Response

```json
{
    "data": {
        "shipmentLocationDTOs": [
            {
                "shipmentLocationId": int,
                "shipmentDetailsId": int,
                "tripId": int,
                "deliveryOrder": int,
                "paymentType": "Prepaid" | "COD",
                "cashAmount": double,
                "orderType": "PICKUP" | "DELIVER",
                "clientNodePhone": string,
                "clientNodeName": "int:string",
                "endTimeWindow": int,
                "address": string,
                "shipmentNotes": string,
                "streetName": string,
                "apartment": string
            }
        ],
        "shipmentCrateMobileDTOs": [
            {
                "shipmentDetailsId": int,
                "crateAmount": double,
                "crateCd": string,
                "crateType" string
            }
        ]
    }
}
```

### Code

- 200: OK
- 401: Logged out

# `GET https://products.loginextsolutions.com/ShipmentApp/mobile/shipment/list?version=466&paramkey=com.loginext.tracknext`

## Request

### Headers

- client_secret_key
- www-authenticate

### Body

```json
{}
```

## Response

### Body

```json
{
    "data": {
        "shipmentLocationDTOs": [
            {
                "shipmentLocationId": int,
                "shipmentDetailsId": int,
                "tripId": int,
                "deliveryOrder": int,
                "paymentType": "Prepaid" | "COD",
                "cashAmount": double,
                "orderType": "PICKUP" | "DELIVER",
                "clientNodePhone": string,
                "clientNodeName": "int:string",
                "endTimeWindow": int,
                "address": string,
                "shipmentNotes": string,
                "streetName": string,
                "apartment": string
            }
        ],
        "shipmentCrateMobileDTOs": [
            {
                "shipmentDetailsId": int,
                "crateAmount": double,
                "crateCd": string,
                "crateType" string
            }
        ]
    }
}
```

### Code

- 200: OK
- 401: Logged out

# `GET https://products.loginextsolutions.com/TripApp/trip/lmfm/getStartedTripsByUserId`

## Request

### Headers

- www-authenticate
- client_secret_key

### Body

```json
{}
```

## Request

### Code

- 200: OK
- 401: Logged out

### Body

```json
{
    "data": {
        "tripId": int,
        "estimatedEndDt": int
    }
}
```
