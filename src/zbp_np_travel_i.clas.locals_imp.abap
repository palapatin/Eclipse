CLASS lhc_supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingSupplId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Supplement~setBookingSupplId.
    METHODS Calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~Calculatetotalprice.

ENDCLASS.

CLASS lhc_supplement IMPLEMENTATION.

  METHOD setBookingSupplId.

    DATA: max_bookingsupplid  TYPE /dmo/booking_supplement_id,
          bookingsupplemen    TYPE STRUCTURE FOR READ RESULT znp_supplement_i,
          bookingsuppl_update TYPE TABLE FOR UPDATE znp_travel_i\\Supplement.

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Supplement BY \_Booking
    FIELDS ( BookingUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Booking BY \_Supplement
    FIELDS ( BookingSupplementId )
    WITH CORRESPONDING #( bookings )
    LINK DATA(bookingsuppl_links)
    RESULT DATA(bookingsupplement).

    LOOP AT bookings INTO DATA(booking).


      " initialize the booking id number
      max_bookingsupplid = '00'.

      LOOP AT bookingsuppl_links INTO DATA(bookingsuppl_link) USING KEY id WHERE source-%tky = booking-%tky .
        bookingsupplemen = bookingsupplement[ KEY id
                              %tky = bookingsuppl_link-target-%tky ].

        IF bookingsupplemen-BookingSupplementId > max_bookingsupplid.
          max_bookingsupplid = bookingsupplemen-BookingSupplementId.
        ENDIF.
      ENDLOOP.

      LOOP AT bookingsuppl_links INTO bookingsuppl_link USING KEY id WHERE source-%tky = booking-%tky .
        bookingsupplemen = bookingsupplement[ KEY id
                              %tky = bookingsuppl_link-target-%tky ].

        IF bookingsupplemen-BookingSupplementId IS INITIAL.
          max_bookingsupplid += 1.
          APPEND VALUE #( %tky = bookingsupplemen-%tky
                           BookingSupplementId = max_bookingsupplid
                           ) TO bookingsuppl_update.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " use modify eml statements to update the supplement entity with the new booking supplement id which is max_bookingsupplid
    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY supplement
    UPDATE FIELDS ( bookingsupplementid )
    WITH bookingsuppl_update.

  ENDMETHOD.

  METHOD Calculatetotalprice.

  ReAD eNTITIES OF znp_travel_i in LOCAL MODE
  enTITY supplement by \_travel
  fiELDS ( traveluuid )
  with corrESPONDING #( keys )
  reSULT data(travels).

  modIFY enTITIES OF znp_travel_i in LOCAL MODE
  entITY travel
  exECUTE recalctotalprice
  from corrESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingdate.

    METHODS setBookingid FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingid.
    METHODS Calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~Calculatetotalprice.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD setBookingdate.

  ENDMETHOD.

  METHOD setBookingid.
    DATA: max_bookingid   TYPE /dmo/booking_id,
          booking         TYPE STRUCTURE FOR READ RESULT znp_bookings_i,
          bookings_update TYPE TABLE FOR UPDATE znp_travel_i\\Booking.

    " we are reading booking entity to get the traveluuid field for the current booking instance
    " and store that in travels table
    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY booking BY \_Travel
    FIELDS ( traveluuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    " now read all the bookings related to travel which we got from top from the travels table
    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel BY \_Booking
    FIELDS ( bookingid )
    WITH CORRESPONDING #( travels )
    LINK DATA(booking_links)
    RESULT DATA(bookings).

    LOOP AT travels INTO DATA(travel).


      " initialize the booking id number
      max_bookingid = '0000'.

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = travel-%tky .
        booking = bookings[ KEY id
                              %tky = booking_link-target-%tky ].

        IF booking-BookingId > max_bookingid.
          max_bookingid = booking-BookingId.
        ENDIF.
      ENDLOOP.

      LOOP AT booking_links INTO booking_link USING KEY id WHERE source-%tky = travel-%tky .
        booking = bookings[ KEY id
                              %tky = booking_link-target-%tky ].

        IF booking-BookingId IS INITIAL.
          max_bookingid += 1 .
          APPEND VALUE #( %tky = booking-%tky
                           bookingid = max_bookingid
                           ) TO bookings_update.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    " use modify eml statements to update the booking entity with the new booking id which is max_bookingid
    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY booking
    UPDATE FIELDS ( bookingid )
    WITH bookings_update.

  ENDMETHOD.

  METHOD Calculatetotalprice.

  ReAD eNTITIES OF znp_travel_i in LOCAL MODE
  enTITY booking by \_travel
  fiELDS ( traveluuid )
  with corrESPONDING #( keys )
  reSULT data(travels).

  modIFY enTITIES OF znp_travel_i in LOCAL MODE
  entITY travel
  exECUTE recalctotalprice
  from corrESPONDING #( travels ).


  ENDMETHOD.

ENDCLASS.

CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS setTravelId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelId.
    METHODS setOverallStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setOverallStatus.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejecttravel RESULT result.
    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~deductdiscount RESULT result.
    METHODS GetDefaultsFordeductDiscount FOR READ
      IMPORTING keys FOR FUNCTION Travel~GetDefaultsFordeductDiscount RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~recalctotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculatetotalprice.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validatecustomer.
    METHODS validateagency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateagency.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validatedates.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setTravelId.

    " Read the entity travel
    READ ENTITIES OF znp_travel_i IN LOCAL MODE
         ENTITY travel
         FIELDS ( Travelid )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travel).

    " Delete the record where travel id is already existing.
    DELETE lt_travel WHERE travelid IS NOT INITIAL.

    SELECT SINGLE FROM znp_travel FIELDS MAX( travel_id ) INTO @DATA(lv_travelid_max).

    "modify eml statement
    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
           ENTITY travel
           UPDATE FIELDS ( travelid )
           WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO lv_index
                         ( %tky = ls_travel-%tky
                           travelid = lv_travelid_max + lv_index   )  ).


  ENDMETHOD.

  METHOD setOverallStatus.
    READ ENTITIES OF znp_travel_i IN LOCAL MODE
         ENTITY travel
         FIELDS ( OverallStatus )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_status).

    DELETE lt_status WHERE OverallStatus IS NOT INITIAL.

    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( OverallStatus )
        WITH VALUE #( FOR ls_status IN lt_status
                      ( %tky = ls_status-%tky
                        OverallStatus = 'O'   )  ).

  ENDMETHOD.

  METHOD accepttravel.

    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    overallstatus = 'A' ) ).


    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                               %param = travel ) ).

  ENDMETHOD.

  METHOD rejecttravel.

    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( overallstatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    overallstatus = 'R' ) ).


    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky
                                               %param = travel ) ).

  ENDMETHOD.

  METHOD deductdiscount.

    DATA: travel_for_update TYPE TABLE FOR UPDATE znp_travel_i.

    DATA(keys_temp) = keys.


    LOOP AT keys_temp ASSIGNING FIELD-SYMBOL(<key_temp>) WHERE %param-discount_percent IS INITIAL OR
                                                               %param-discount_percent > 100 OR
                                                               %param-discount_percent < 0.

      APPEND VALUE #(  %tky = <key_temp>-%tky ) TO failed-travel.
      APPEND VALUE #(  %tky = <key_temp>-%tky
                       %msg = new_message_with_text( text = 'Invalid discount percentage'
                                                     severity = if_abap_behv_message=>severity-error )
                       %element-totalprice = if_abap_behv=>mk-on
                       %action-deductDiscount = if_abap_behv=>mk-on ) TO reported-travel.

      DELETE keys_temp.
    ENDLOOP.

    CHECK keys_temp IS NOT INITIAL.

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( totalprice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    DATA: lv_percentage TYPE decfloat16.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_discount_percent) = keys[ KEY id %tky = <fs_travel>-%tky ]-%param-discount_percent.

      lv_percentage = lv_discount_percent / 100.

      DATA(reduced_value) = <fs_travel>-totalprice * lv_percentage.

      reduced_value = <fs_travel>-totalprice - reduced_value.

      APPEND VALUE #( %tky = <fs_travel>-%tky
                      totalprice = reduced_value ) TO travel_for_update.

    ENDLOOP.

    MODIFY ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( totalprice )
    WITH travel_for_update.


    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_travel_updated).

    result = VALUE #( FOR ls_travel IN lt_travel_updated ( %tky = ls_travel-%tky
                                                           %param = ls_travel ) ).



  ENDMETHOD.

  METHOD GetDefaultsFordeductDiscount.

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-TotalPrice >= 4000.
        APPEND VALUE #( %tky = travel-%tky
                        %param-discount_percent = 30 ) TO result.
      ELSE.
        APPEND VALUE #( %tky = travel-%tky
                        %param-discount_percent = 15 ) TO result.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD recalctotalprice.

    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.


    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( bookingfee currencycode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY travel BY \_booking
    FIELDS ( flightprice currencycode )
    WITH CORRESPONDING #( travels )
    RESULT DATA(bookings)
    LINK DATA(booking_links).

    READ ENTITIES OF znp_travel_i IN LOCAL MODE
    ENTITY booking BY \_supplement
    FIELDS ( price currencycode )
    WITH CORRESPONDING #( bookings )
    RESULT DATA(supplements)
    LINK DATA(supplements_links).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      amounts_per_currencycode = VALUE #( ( amount = <travel>-bookingfee
                                          currency_code =  <travel>-CurrencyCode ) ).

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = <travel>-%tky.

        DATA(booking) = bookings[ KEY id %tky = booking_link-target-%tky ].
        COLLECT VALUE ty_amount_per_currencycode( amount = booking-FlightPrice
                                                  currency_code = booking-CurrencyCode ) INTO amounts_per_currencycode.

        LOOP AT supplements_links INTO DATA(supplement_link) USING KEY id WHERE source-%tky = booking-%tky.

          DATA(supplement) = supplements[ KEY id %tky = supplement_link-target-%tky ].
          COLLECT VALUE ty_amount_per_currencycode( amount = supplement-Price
                                                    currency_code = supplement-CurrencyCode ) INTO amounts_per_currencycode.


        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

   DeLETE amounts_per_currencycode where currency_code is iniTIAL .

   loop at amounts_per_currencycode into data(amount_per_currencycode).

   if  <travel>-CurrencyCode = amount_per_currencycode-currency_code.
       <travel>-TotalPrice += amount_per_currencycode-amount.

   elSE.
       /dmo/cl_flight_amdp=>convert_currency(
              ExpoRTING
                iv_amount = amount_per_currencycode-amount
                iv_currency_code_source = amount_per_currencycode-currency_code
                iv_currency_code_target = <travel>-CurrencyCode
                iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
             IMPORTING
                ev_amount              = data(total_booking_price_per_curr)
        ).

        <travel>-TotalPrice += total_booking_price_per_curr.

   enDIF.

   ModIFY entiTIES OF znp_travel_i in LOCAL MODE
   enTITY travel
   upDATE fieLDS ( totalprice )
   with corrESPONDING #( travels ).

   endloop.

  ENDMETHOD.

  METHOD calculatetotalprice.

   ModiFY entITIES OF znp_travel_i in loCAL MODE
   enTITY travel
   exECUTE recalctotalprice
   from corrESPONDING #( Keys ).

  ENDMETHOD.

  METHOD validatecustomer.

  reAD entiTIES OF znp_travel_i in local MODE
  enTITY travel
  fiELDS ( customerid  )
  with corrESPONDING #( keys )
  resULT data(travels).

  data: customers type sorTED TABLE OF /dmo/customer with unIQUE keY customer_id.
  customers = correSPONDING #( travels disCARDING DUPLICATES maPPING customer_id = customerid exCEPT * ).

  select from /dmo/customer fielDS customer_id
  for ALL ENTRIES IN @customers
  where customer_id = @customers-customer_id
  into table @data(valid_customers).

  looP AT travels into data(travel).

  if travel-CustomerId is not inITIAL and not line_exists( valid_customers[ customer_id = travel-CustomerId ] ).
     append value #( %tky = travel-%tky ) to failed-travel.

     append value #( %tky = travel-%tky
                     %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = |Not a valid customer { travel-CustomerId }| )
                     %element-customerid = if_abap_behv=>mk-on  ) to reported-travel.
  else.

  Endif.

  endlOOP.




  ENDMETHOD.

  METHOD validateagency.

  reAD entiTIES OF znp_travel_i in local MODE
  enTITY travel
  fiELDS ( AgencyId  )
  with corrESPONDING #( keys )
  resULT data(travels).

  data: agencies type sorTED TABLE OF /dmo/agency with unIQUE keY agency_id.
  agencies = correSPONDING #( travels disCARDING DUPLICATES maPPING agency_id = agencyid exCEPT * ).

  select from /dmo/agency fielDS agency_id
  for ALL ENTRIES IN @agencies
  where agency_id = @agencies-agency_id
  into table @data(valid_agencies).

  looP AT travels into data(travel).

  if travel-agencyid is not inITIAL and not line_exists( valid_agencies[ agency_id = travel-agencyid ] ).
     append value #( %tky = travel-%tky ) to failed-travel.

     append value #( %tky = travel-%tky
                     %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = |Not a valid agency { travel-agencyid }| )
                     %element-agencyid = if_abap_behv=>mk-on  ) to reported-travel.
  else.

  Endif.

  endlOOP.


  ENDMETHOD.

  METHOD validatedates.

  reAD entiTIES OF znp_travel_i in local MODE
  enTITY travel
  fiELDS ( BeginDate EndDate  )
  with corrESPONDING #( keys )
  resULT data(travels).

  loop at travels into data(travel).

  if travel-BeginDate is inITIAL.
     append value #( %tky = travel-%tky ) to failed-travel.

     append value #( %tky = travel-%tky
                     %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = |Begin date shold not be blank| )
                     %element-begindate = if_abap_behv=>mk-on  ) to reported-travel.
  endif.

  if travel-endDate is inITIAL.
     append value #( %tky = travel-%tky ) to failed-travel.

     append value #( %tky = travel-%tky
                     %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = |End date shold not be blank| )
                     %element-enddate = if_abap_behv=>mk-on  ) to reported-travel.
  endif.

  if travel-BeginDate is not inITIAL and travel-EndDate is not inITIAL and travel-EndDate < travel-BeginDate.
     append value #( %tky = travel-%tky ) to failed-travel.

     append value #( %tky = travel-%tky
                     %msg = new_message_with_text(
                            severity = if_abap_behv_message=>severity-error
                            text = |Begin date shold not be grater thanEenddate| )
                     %element-begindate = if_abap_behv=>mk-on
                     %element-enddate = if_abap_behv=>mk-on
                     ) to reported-travel.
  endif.

  endloop.

  ENDMETHOD.

ENDCLASS.
