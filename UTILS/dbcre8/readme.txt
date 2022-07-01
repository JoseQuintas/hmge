ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
ณ    *** The SuccessWare Index (SIx) Driver v3.02 for CA-Clipper 5.2x ***    ณ
ณ                Copyright 1992-96 - SuccessWare 90, Inc.                    ณ
ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

  We have provided you with a small utility called DBCRE8.EXE which you can
  use to quickly create a test database file full of pseudo-random data.  You
  can also optionally create an associated memo file in either the CA-Clipper
  (.DBT), FoxPro (.FPT), or SuccessWare (.SMT) formats.  VariField "V" field
  types are also supported.

  The structure of the database files created by the DBCRE8 utility is as
  follows:

          NAME        TYPE LEN DEC
          ----------- ---- --- ---
          FIRST       C     20
          LAST        C     20
          STREET      C     30
          CITY        C     30
          STATE       C      2
          ZIP         C     10
          HIREDATE    D      8
          MARRIED     L      1
          AGE         N      2   0
        * SALARY      N      6   0
       ** NOTES       C     70


   (*) The SALARY field's DEC value becomes 2 if the /d switch is used.

  (**) If the /mD or /mF switch is used, this field will become a memo field
       (Type "M") with a length of 10.

  The command-line syntax for using DBCRE8.EXE is as follows:

      DBCRE8 <nRecs> [options]

      Where:  <nRecs> = Number of records to add to the DBF file.

    Options:  /d = Make SALARY field use <n> decimal places.  ( Ex: /d3 ).
                   The specified value can be from 1-4.  The default is 2.

              /e = Encrypt the DBF with password.  Ex:  /ePASSWORD.

              /f = Optional DBF file name to create.  Ex: /fBOGUS.  The
                   default data file name is TEST.

             /mD = Include MEMO field using DBT format.

             /mF = Include MEMO field using FPT format.  An optional memo
                   block size can also be set by immediately following the
                   \"F\" with a colon followed by the desired block size.
                   Ex:  /mF:512 or /mF:16.  This value can be any value
                   between 1 and 1024.  The default value is 32.

             /mS = Include MEMO field using SMT format.  An optional memo
                   block size can also be set as with the /mF switch (above).
                   The default value is 1.

              /r = Randomize record data.  (Creates unique data sets.)

              /s = Silent operation (no screen output at all).

           /vF|S = Use VariFields with FPT memo or SMT memo format.

           /x<n> = Mark every <n>th record as deleted.  Ex:  /x10.


  Examples:

    Create TEST.DBF with 1000 records ...........:  DBCRE8 1000

    Same as above, encrypted with password "FOO" :  DBCRE8 1000 /eFOO

    Create BOGUS.DBF with 500 records ...........:  DBCRE8 500 /fBOGUS

    Create TEST.DBF and TEST.DBT with 100 records:  DBCRE8 100 /mD

    Create FOO.DBF and FOO.FPT with 250 records .:  DBCRE8 250 /mF /fFOO

    Create FOO.DBF and FOO.SMT w/ 32-byte blocks :  DBCRE8 250 /mS:32 /fFOO

    Create TEST.DBF w/ 2 decimal places in SALARY:  DBCRE8 1000 /d

    Create DEMO.DBF w/ 3 decimal places in SALARY:  DBCRE8 1000 /d3 /fDEMO

    Create TEST.DBF and TEST.SMT w/ VariFields   :  DBCRE8 1000 /vS
