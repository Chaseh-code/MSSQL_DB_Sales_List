/*** Purpose of this query to create essentially a calling list
*** This report will grab all the items based off when they were last purchased in SAP, based off the
*** item master data, in a date range. That list is then filtered down to show the last A/R Invoice
*** for each of those items, and checks if the selling price for them was >= $3000.
*** This would give the team a reference of when the customer has last purchased the item from us
*** and can give us a chance to call them about reordering an item after a certain time period.
***/

Declare @startdate as date, @enddate as date
select @startdate = '6/1/21', @enddate = '9/1/21'

SELECT      T1.CardCode as 'BP'
            ,T1.CardName as 'BP Name'
            ,T0.ItemCode as 'Item Code'
            ,T0.ItemName as 'Item Name'
            ,T0.FrgnName as 'Print Name'
            ,T2.MaxDoc as 'Doc Num'
            ,T5.DocDate as 'Posting Date'
            ,T6.LineTotal as 'Item Total'
            ,T0.LastPurDat
            --,T5.CANCELED      
            
FROM    OITM T0 /*** pulls in the items for us to look at ***/
        inner join OCRD T1 on SUBSTRING(T0.ItemCode,5,6) = T1.CardCode
        inner join ( /*** grabs the last invoice for each item ***/
            select T4.ItemCode, MAX(T3.DocEntry) as MaxDoc
            from OINV T3 inner join INV1 T4 on T3.DocEntry = T4.DocEntry
            group by T4.ItemCode
            ) T2 on T0.ItemCode = T2.ItemCode
        inner join ( /*** grabs the posting date for the last invoice for each item. Also helps check if the invoice was cancelled ***/
            select DocEntry, DocDate, CANCELED
            from OINV 
            ) T5 on T2.MaxDoc = T5.DocEntry
        inner join ( /*** grabs the sale price for the item on the correct invoice ***/
            select ItemCode, DocEntry, LineTotal
            from INV1
            ) T6 on T0.ItemCode = T6.ItemCode and T2.MaxDoc = T6.DocEntry

WHERE   T0.LastPurDat between @startdate and @enddate
        and T6.LineTotal >= 3000
        and T5.CANCELED = 'N'

ORDER BY    T1.CardCode
            ,T2.MaxDoc
         