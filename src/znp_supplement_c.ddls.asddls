@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplement Consumption'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
define view entity ZNP_SUPPLEMENT_C as projection on ZNP_Supplement_I
{
    key SupplementUuid,
    TravelUuid,
    BookingUuid,
    BookingSupplementId,
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _booking: redirected to parent ZNP_BOOKINGS_C,
    _travel: redirected to ZNP_TRAVEL_C
}
