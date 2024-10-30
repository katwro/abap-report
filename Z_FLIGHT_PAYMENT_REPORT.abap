*&---------------------------------------------------------------------*
*& Report Z_FLIGHT_PAYMENT_REPORT
*&---------------------------------------------------------------------*
*& This report displays flight information and calculates payment sums
*& for each carrier. It includes detailed information on selection.
*&---------------------------------------------------------------------*
REPORT z_flight_payment_report.

TABLES : sflight, spfli, scarr.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: s_carrid FOR sflight-carrid NO INTERVALS,
                s_fldate FOR sflight-fldate NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b1.

DATA : lt_sflight    TYPE TABLE OF sflight,
       ls_sflight    TYPE sflight,
       lt_spfli_hash TYPE HASHED TABLE OF spfli WITH UNIQUE KEY carrid connid,
       ls_spfli      TYPE spfli,
       lt_scarr_hash TYPE HASHED TABLE OF scarr WITH UNIQUE KEY carrid,
       ls_scarr      TYPE scarr.

DATA : gv_line   TYPE i,
       gv_offset TYPE i VALUE 4.

TYPES: BEGIN OF ty_summary,
         carrid           TYPE sflight-carrid,
         carrname         TYPE scarr-carrname,
         total_paymentsum TYPE sflight-paymentsum,
         currency         TYPE scarr-currcode,
       END OF ty_summary.

DATA: lt_summary TYPE TABLE OF ty_summary,
      ls_summary TYPE ty_summary.

AT SELECTION-SCREEN ON s_fldate.
  IF s_fldate-high IS INITIAL.
    s_fldate-high = sy-datum.
  ENDIF.

START-OF-SELECTION.
  PERFORM fetch_data.

END-OF-SELECTION.
  PERFORM display_data.

AT LINE-SELECTION.
  PERFORM display_details.

*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA
*&---------------------------------------------------------------------*
*       Fetch data from tables SFLIGHT and SPFLI
*---------------------------------------------------------------------*
FORM fetch_data.
  SELECT * FROM sflight
   WHERE carrid IN @s_carrid AND
         fldate BETWEEN @s_fldate-low AND @s_fldate-high
   INTO TABLE @lt_sflight.

  SELECT * FROM spfli INTO TABLE @lt_spfli_hash.
  SELECT * FROM scarr INTO TABLE @lt_scarr_hash.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       Display data from SFLIGHT and SPFLI
*---------------------------------------------------------------------*
FORM display_data.
  WRITE :/(10) 'Carrier', (15) 'Date', (15) 'From', (15) 'To', (15) 'Price', (15) 'Payment Sum', (10) 'Currency'.
  ULINE.

  LOOP AT lt_sflight INTO ls_sflight.
    READ TABLE lt_spfli_hash INTO ls_spfli WITH KEY carrid = ls_sflight-carrid connid = ls_sflight-connid.

    IF sy-subrc = 0.
      WRITE :/(10) ls_sflight-carrid, (15) ls_sflight-fldate, (15) ls_spfli-cityfrom, (15) ls_spfli-cityto,
              (15) ls_sflight-price LEFT-JUSTIFIED, (15) ls_sflight-paymentsum LEFT-JUSTIFIED, (10) ls_sflight-currency.

      READ TABLE lt_summary WITH KEY carrid = ls_sflight-carrid INTO ls_summary.

      IF sy-subrc <> 0.
        ls_summary-carrid = ls_sflight-carrid.
        ls_summary-total_paymentsum = ls_sflight-paymentsum.

        READ TABLE lt_scarr_hash INTO ls_scarr WITH KEY carrid = ls_sflight-carrid.

        IF sy-subrc = 0.
          ls_summary-carrname = ls_scarr-carrname.
          ls_summary-currency = ls_scarr-currcode.
        ENDIF.

        APPEND ls_summary TO lt_summary.
      ELSE.
        ADD ls_sflight-paymentsum TO ls_summary-total_paymentsum.
        MODIFY lt_summary FROM ls_summary INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

  ULINE.
  WRITE :/ '---------------- Summary by Carrier ----------------'.
  SKIP.

  LOOP AT lt_summary INTO ls_summary.
    WRITE: / ls_summary-carrname, ls_summary-carrid, ls_summary-total_paymentsum, ls_summary-currency.
    SKIP.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DETAILS
*&---------------------------------------------------------------------*
*       Display detailed information
*---------------------------------------------------------------------*
FORM display_details.
  GET CURSOR LINE gv_line.

  gv_line = gv_line - gv_offset.

  READ TABLE lt_sflight INTO ls_sflight INDEX gv_line.

  IF sy-subrc = 0.
    READ TABLE lt_spfli_hash INTO ls_spfli WITH KEY carrid = ls_sflight-carrid connid = ls_sflight-connid.

    IF sy-subrc = 0.
      WRITE :/ '----- Detailed Information -----'.
      SKIP.
      WRITE :/ 'Carrier ID',20 ls_sflight-carrid,
             / 'Connection ID',20 ls_sflight-connid,
             / 'Flight Date',20 ls_sflight-fldate,
             / 'From',20 ls_spfli-cityfrom,
             / 'To',20 ls_spfli-cityto,
             / 'Price',20 ls_sflight-price LEFT-JUSTIFIED,
             / 'Currency',20 ls_sflight-currency,
             / 'Plane Type',20 ls_sflight-planetype,
             / 'Seats Max',20 ls_sflight-seatsmax LEFT-JUSTIFIED,
             / 'Seats Occupied',20 ls_sflight-seatsocc LEFT-JUSTIFIED.
    ENDIF.
  ENDIF.
ENDFORM.