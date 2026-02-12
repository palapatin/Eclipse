@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Naren Supplement entity'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZNP_Supplement_I
  as select from znp_supplement
  association     to parent ZNP_BOOKINGS_I 
  as _booking on $projection.BookingUuid = _booking.BookingUuid
  association [1] to ZNP_TRAVEL_I          
  as _travel  on $projection.TravelUuid = _travel.TravelUuid
{
  key supplement_uuid       as SupplementUuid,
      root_uuid             as TravelUuid,
      parent_uuid           as BookingUuid,
      booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt
      local_last_changed_at as LocalLastChangedAt,
      _booking, // Make association public
      _travel
}
