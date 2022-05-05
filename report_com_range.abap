*&---------------------------------------------------------------------*
*& Report Z_TA_03_REPORT_RANGES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ta_03_report_ranges.
TABLES:scarr,
       spfli,
       sflight.

DATA: r_airlineid  TYPE RANGE OF sflights2-carrid.
DATA: r_datarange  TYPE RANGE OF sflights2-fldate.

r_airlineid = VALUE #( ( sign = 'I' option = 'BT' low = 'AA' high = 'LH' ) ).
r_datarange = VALUE #( ( sign = 'I' option = 'BT' low = '20210101' high = '20211212' ) ).

START-OF-SELECTION.

  DATA: gt_flights TYPE TABLE OF sflights2,
        wa_flights TYPE sflights2.

  DATA: gt_scarr_spfli_flight TYPE zscarr_spfli_flight. " Tipo tabela "
  DATA: wa_scarr_spfli_flight TYPE zscarr_spfli_flight_st. " Estrutura da tabela "


*  PERFORM select_with_innerjoins.
  PERFORM select_with_forallentries.

END-OF-SELECTION.

*  PERFORM apresentadados.


FORM select_with_forallentries.

  TYPES: BEGIN OF ty_spfli,
           carrid    TYPE spfli-carrid,
           connid    TYPE spfli-connid,
           countryfr TYPE spfli-countryfr,
           cityfrom  TYPE spfli-cityfrom,
           airpfrom  TYPE spfli-airpfrom,
           countryto TYPE spfli-countryto,
           cityto    TYPE spfli-cityto,
           airpto    TYPE spfli-airpto,
           fltime    TYPE spfli-fltime,
           deptime   TYPE spfli-deptime,
           arrtime   TYPE spfli-arrtime,
           distance  TYPE spfli-distance,
         END OF ty_spfli.

  TYPES: BEGIN OF ty_scarr,
           carrid   TYPE scarr-carrid,
           carrname TYPE scarr-carrname,
           currcode TYPE scarr-currcode,
         END OF ty_scarr.

  TYPES: BEGIN OF ty_sflight,
           carrid TYPE sflight-carrid,
           connid TYPE sflight-connid,
           fldate TYPE sflight-fldate,
         END OF ty_sflight.

        " Declarando tabelas internas "
  DATA: it_scarr   TYPE TABLE OF ty_scarr,
        it_spfli   TYPE TABLE OF ty_spfli,
        it_sflight TYPE TABLE OF ty_sflight,
          " Declarando work areas "
        wa_scarr   TYPE ty_scarr,
        wa_spfli   TYPE ty_spfli,
        wa_sflight TYPE ty_sflight.


  SELECT
    scarr~carrid
    scarr~carrname
    scarr~currcode
    INTO TABLE it_scarr
    FROM scarr AS scarr
    WHERE scarr~carrid IN r_airlineid. " Condição: se carrid for igual ao range..."

  IF it_scarr[] IS NOT INITIAL.

    SELECT
          carrid
          connid
          countryfr
          cityfrom
          airpfrom
          countryto
          cityto
          airpto
          fltime
          deptime
          arrtime
          distance
     FROM spfli " Transparent Table "
     INTO TABLE it_spfli " Internal Table "
       FOR ALL ENTRIES IN it_scarr
     WHERE carrid = it_scarr-carrid.

      SELECT
        carrid
        connid
        fldate
      FROM sflight
        INTO TABLE it_sflight
           FOR ALL ENTRIES IN it_spfli
        WHERE carrid = it_spfli-carrid AND
              connid = it_spfli-connid AND
              fldate IN r_datarange.

    SORT it_sflight by carrid.
    LOOP AT it_scarr INTO wa_scarr.
     LOOP AT it_spfli INTO wa_spfli WHERE carrid = wa_scarr-carrid.
       READ TABLE it_sflight ASSIGNING FIELD-SYMBOL(<fs_sflight>) WITH KEY carrid = wa_spfli-carrid BINARY SEARCH.
       MOVE <fs_sflight>-fldate TO wa_sflight-fldate.

       WRITE: / wa_scarr-carrid,
                wa_scarr-carrname,
                wa_scarr-currcode,
                wa_spfli-connid,
                wa_spfli-countryfr,
                wa_spfli-cityfrom,
                wa_spfli-airpfrom,
                wa_spfli-countryto,
                wa_spfli-cityto,
                wa_spfli-airpto,
                wa_spfli-fltime,
                wa_spfli-deptime,
                wa_spfli-arrtime,
                wa_spfli-distance,
                wa_sflight-fldate.
     ENDLOOP.
  ENDLOOP.

  ENDIF.
ENDFORM.

*FORM select_with_innerjoins.
*  SELECT
*        scarr~carrid
*        scarr~carrname
*        scarr~currcode
*        spfli~countryto
*        spfli~cityfrom
*        spfli~cityto
*   INTO  TABLE it_scarr" tabela interna (dados local)"
*   FROM sflight AS sflight " tabela transparente (dados no banco)"
*   INNER JOIN scarr AS scarr  ON scarr~carrid   = sflight~carrid
*   INNER JOIN spfli AS spfli  ON spfli~carrid   = sflight~carrid AND spfli~connid = sflight~connid
*
*    WHERE sflight~carrid IN r_airlineid AND
*          fldate         IN r_datarange. " Vai dar um select where carrid estiver no range(gt_airlineid) que está com os parametros entre AA e AZ"
*ENDFORM.

FORM apresentadados.
  LOOP AT gt_scarr_spfli_flight INTO wa_scarr_spfli_flight.
    IF sy-subrc = 0.
      WRITE: /  wa_scarr_spfli_flight-CARRID,
                wa_scarr_spfli_flight-CONNID,
                wa_scarr_spfli_flight-COUNTRYFR,
                wa_scarr_spfli_flight-CITYFROM,
                wa_scarr_spfli_flight-AIRPFROM,
                wa_scarr_spfli_flight-COUNTRYTO,
                wa_scarr_spfli_flight-CITYTO,
                wa_scarr_spfli_flight-AIRPTO,
                wa_scarr_spfli_flight-FLTIME,
                wa_scarr_spfli_flight-DEPTIME,
                wa_scarr_spfli_flight-ARRTIME,
                wa_scarr_spfli_flight-DISTANCE,
                wa_scarr_spfli_flight-DISTID,
                wa_scarr_spfli_flight-FLTYPE,
                wa_scarr_spfli_flight-PERIOD.

    ENDIF.
  ENDLOOP.
ENDFORM.