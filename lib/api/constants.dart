const String userAgent = "KFCDeliApp";
const String platform = "KFC";
const String version = "5.0.99";

const String baseUrl = "https://products.loginextsolutions.com/";
const String loginUrl = baseUrl + "LoginApp/login/mobile/authenticate";
const String logoutUrl = baseUrl + "LoginApp/login/mobile/logout";
const String breakUrl =
    baseUrl + "DeliveryMediumApp/deliverymedium/fmlm/mobile/mark/break";
const String getStartedTripsUlr =
    baseUrl + "TripApp/trip/lmfm/getStartedTripsByUserId";
const String getHistoryUrl = baseUrl +
    "DeliveryMediumApp/deliverymedium/fmlm/mobile/dmhistory?pageSize=100";
const String tripIdUrl = baseUrl + "TripApp/trip/lmfm/getStartedTripsByUserId";
const String checkinUrl =
    baseUrl + 'ShipmentApp/mobile/shipment/mile/checkin?path_param_url=1729';
const String checkoutUrl =
    baseUrl + 'ShipmentApp/mobile/shipment/mile/mark?path_param_url=1729';
const String paymentUrl =
    baseUrl + 'ShipmentApp/mobile/shipment/payment/v2?path_param_url=1729';
const String ordersUrl = baseUrl +
    'ShipmentApp/mobile/shipment/list?version=466&paramkey=com.loginext.tracknext';
