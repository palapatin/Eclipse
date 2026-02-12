CLASS lhc_supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingSupplId FOR DETERMINE ON SAVE
      IMPORTING keys FOR Supplement~setBookingSupplId.

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

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setBookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingdate.

    METHODS setBookingid FOR DETERMINE ON SAVE
      IMPORTING keys FOR Booking~setBookingid.

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

ENDCLASS.
