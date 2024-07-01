
CREATE TABLE artists
(
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks
(
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales
(
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists
    (artist_id, name, country, birth_year)
VALUES
    (1, 'Vincent van Gogh', 'Netherlands', 1853),
    (2, 'Pablo Picasso', 'Spain', 1881),
    (3, 'Leonardo da Vinci', 'Italy', 1452),
    (4, 'Claude Monet', 'France', 1840),
    (5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks
    (artwork_id, title, artist_id, genre, price)
VALUES
    (1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
    (2, 'Guernica', 2, 'Cubism', 2000000.00),
    (3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
    (4, 'Water Lilies', 4, 'Impressionism', 500000.00),
    (5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales
    (sale_id, artwork_id, sale_date, quantity, total_amount)
VALUES
    (1, 1, '2024-01-15', 1, 1000000.00),
    (2, 2, '2024-02-10', 1, 2000000.00),
    (3, 3, '2024-03-05', 1, 3000000.00),
    (4, 4, '2024-04-20', 2, 1000000.00)



--### Section 1: 1 mark each

--1. Write a query to display the artist names in uppercase.

select UPPER(name)
from artists

--2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.
select total_amount
from sales
where artwork_id=(select artwork_id
from artworks
where title='Mona Lisa')

--3. Write a query to calculate the price of 'Starry Night' plus 10% tax.

select price+(price*0.1) as price
from artworks
where title='Starry Night'


--4. Write a query to extract the year from the sale date of 'Guernica'.

select year(sale_date) as sale_year
from sales
    join artworks
    on sales.artwork_id=artworks.artwork_id
where title='Guernica'




--### Section 2: 2 marks each

--5. Write a query to display artists who have artworks in multiple genres.
select name
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
group by  name
having count(distinct genre)>1


--6. Write a query to find the artworks that have the highest sale total for each genre.


with
    cte_HighestSalesGenre
    as
    (
        select title, genre, total_amount,
            Rank() over (partition by genre order by total_amount desc) as rank
        from artworks
            join sales
            on artworks.artwork_id=sales.artwork_id
    )
select *
from cte_HighestSalesGenre
where rank=1


--7. Write a query to find the average price of artworks for each artist.

select name, avg(price) as avg_price
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
group by artworks.artist_id,name


--8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.



select top(2)
    title, price, sum(quantity) as Total_quantity
from artworks
    join sales
    on artworks.artwork_id=sales.artwork_id
group by artworks.artwork_id,title,price
order by price desc


--9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.


select avg(quantity)
from sales

select name
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
    join sales
    on sales.artwork_id=artworks.artwork_id
where quantity > (select avg(quantity)
from sales)


--10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.


select *
from artists as a1
where birth_year <  ( select avg(birth_year)
from artists as a2
where a1.country=a2.country)


--11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.



    select name
    from artists
        join artworks
        on artists.artist_id=artworks.artist_id
    where genre='Cubism'
intersect
    select name
    from artists
        join artworks
        on artists.artist_id=artworks.artist_id
    where genre='Surrealism'

--12. Write a query to find the artworks that have been sold in both January and February 2024.


    select title
    from artworks
        join sales
        on artworks.artwork_id=sales.artwork_id
    where Format(sale_date,'yyyy MMMM')='2024 January'
intersect
    select title
    from artworks
        join sales
        on artworks.artwork_id=sales.artwork_id
    where Format(sale_date,'yyyy MMMM')='2024 February'


--13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.


select name, avg(price) as avg_price
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
group by artists.artist_id, name
having avg(price) > all (select price
from artworks
where genre='Renaissance')
--14. Write a query to rank artists by their total sales amount and display the top 3 artists.


with
    cte_Artists
    as
    (
        select name,
            Rank() over (order by total_amount desc) as rank
        from artists
            join artworks
            on artists.artist_id=artworks.artist_id
            join sales
            on artworks.artwork_id=sales.artwork_id
    )
select *
from cte_Artists
where rank<=3

--15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

create nonclustered index IX_Sales_artwork
on sales ([artwork_id])


select *
from sales
where artwork_id=1

--### Section 3: 3 Marks Questions

--16.  Write a query to find the average price of artworks for each artist and only include artists 
--whose average artwork price is higher than the overall average artwork price.

select avg(price)
from artworks

select name, avg(price) as avg_price
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
group by artists.artist_id,name
having avg(price) >(select avg(price)
from artworks)

--17.  Write a query to create a view that shows artists who have created artworks in multiple genres.

go
create view vWArtistsMutlipleGenre
as
    select name
    from artists
        join artworks
        on artists.artist_id=artworks.artist_id
    group by  name
    having count(distinct genre)>1
go
select *
from vWArtistsMutlipleGenre

--18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.


select title
from artworks as a1
where price < ( select avg(price)
from artworks as a2
where a1.artist_id=a2.artist_id)

--### Section 4: 4 Marks Questions


--19.  Write a query to convert the artists and their artworks into JSON format.


select name as [artits],
    title as 'artist.title'
from artists
    join artworks
    on artists.artist_id=artworks.artist_id
for json path,root('artwork')

    --20.  Write a query to export the artists and their artworks into XML format.
    select name as [@artits],
        title as [artist/title]
    from artists
        join artworks
        on artists.artist_id=artworks.artist_id
    for xml path('Artists'),root('artwork')

        --#### Section 5: 5 Marks Questions

        --21. Create a stored procedure to add a new sale and update the total sales for the artwork. 
        --Ensure the quantity is positive, and use transactions to maintain data integrity.
        select *
        from artists
        select *
        from sales
        select *
        from artworks
go
        create proc sp_Sales
            @sale_id int,
            @artwork_id int,
            @sale_date Date,
            @quantity int,
            @total_amount decimal(10,2)
        as
        begin
            begin transaction;
            begin try
		    if (@quantity<0)
			 throw 60000,'quantity is invalid',1;
			  
			  insert into sales
            values(@sale_id, @artwork_id, @sale_date, @quantity, @total_amount)
			  commit transaction;
			  end try
		begin catch
		   rollback transaction
		   print(concat('error message ',Error_message()))
		end catch
        end
go
        exec sp_Sales  5,1,'2024-03-12',1,10000.00
        exec sp_Sales  6,1,'2024-09-09',-3,1099.00

        --22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each 
        --genre and use it in a query to display the results.
        select genre, sum(quantity)
        from sales
            join artworks
            on sales.artwork_id=artworks.artwork_id
        group by genre

go
        create function TotalQuantitySold()
returns @mtvftotalquantity table(genre varchar(30),
            quantity int)
as
begin
            insert into @mtvftotalquantity
            select genre, sum(quantity)
            from sales
                join artworks
                on sales.artwork_id=artworks.artwork_id
            group by genre
            return
        end
go

        select *
        from TotalQuantitySold()

--23. Create a scalar function to calculate the average sales amount for artworks in a given 
--genre and write a query to use this function for 'Impressionism'.

go
        create function AvgSalesAmount(@genre nvarchar(50))
returns decimal(10,2)
as
begin
            return(select avg(total_amount)
            from sales
                join artworks
                on sales.artwork_id=artworks.artwork_id
            where genre=@genre)
        end
go
        --drop function AvgSalesAmount
        select *
        from AvgSalesAmount('Impressionism')



--24. Create a trigger to log changes to the `artworks` table into an 
--`artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
go
        alter trigger trg_artworks
on artworks
after insert
as
begin

            insert into artwork_log
            select artwork_id, title, 'new row inserted'
            from inserted

        end

create table artwork_log
        (
            artwork_id int,
            title nvarchar(50),
            Change_description nvarchar(100)
        );

select *
        from artwork_log



--25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.


select name,
            ntile (4) over (order by count(quantity))
        from artists
            join artworks
            on artists.artist_id=artworks.artist_id
            join sales
            on artworks.artwork_id=sales.artwork_id
        group by artists.artist_id,name

--### Normalization (5 Marks)

--26. **Question:**
--    Given the denormalized table `ecommerce_data` with sample data:

--| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
--| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
--| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
--| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
--| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
--| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

--Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

--### ER Diagram (5 Marks)

--27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.

CREATE TABLE [Customers]
        (
            [ Customer_id] int,
            [name] nvarchar(30) not null,
            [email] nvarchar(50) not null unique,
            PRIMARY KEY ([ Customer_id])
        );

CREATE TABLE [Product_price]
        (
            [Product_id] int,
            [product_name] nvarchar(30) not null unique,
            [Product_category] nvarchar(30) unique,
            [Product_price] decimal(10,2),
            PRIMARY KEY ([Product_id])
        );
CREATE TABLE [Orders]
        (
            [Order_id] int,
            [Order_date] Date not null,
            [Order_quantity] int not null,
            [Order_Amount] decimal(10,2) not null,
            PRIMARY KEY ([Order_id])
        );


CREATE TABLE [Mapping]
        (
            [id] int Primary Key,
            [Customer_id] int not null,
            [Order_id] int not null,
            [Product_id] int not null,
            foreign key (Customer_id) references Customers(Customer_id),
            foreign key (Order_id) references Orders(Order_id),
            foreign key (Product_id) references Products(Product_id)
        );



