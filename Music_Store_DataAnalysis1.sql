/*Question Set 1 - Easy*/

/*Q1: Who is the senior most employee basen on job title?*/

select * from employee
order by levels desc
limit 1

/*Q2: Which country has the most invoices?*/

select count(*) as c,billing_country 
from Invoice
group by billing_country
order by c desc

Answer: USA

/*Q3: what are top 3 values of total invoice?8*/

select total from Invoice
order by total desc
limit 3

/*Q4: Which city has the best customer? We would like to throw a promotional
Music Festical in the city we made the most money. Write a query that 
returns one city that has the highest sum of invoice totals. Return both
vity name & sum of all invoice totals.*/

select sum(total) as invoice_total, billing_city
from Invoice
group by billing_city
order by invoice_total desc

/*Q5: Who is the  best customer? The customer who has spend the most money
will be declared the best customer. Write a query that returns the person 
who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

/*Question Set 2 - Moderate*/

/*Q1: Write a query to return the email, first name, last name, & Genre of all Rock
Music Listeners. Return your list ordered alphabetically by email starting with A.*/

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

/*Q2: Lets invite the artist who has written the most rock music in our dataset.
write a query that returns the Artist name and total track counts
of the top 10 rock bands*/

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

/*Q3: Return all the track names that have a strong length longer than
the average song length. Return the name and milisecond for
each track. Order by the song length with the longest songs listed
first.*/

select name, milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;

/*Question Set 3 - Advance*/

/*Q1: Find how much amount spent by each customer on artists? Write a 
query to return customer name, artist name and total spent*/

with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/*Q2: We want to find out the most popular genre for each country.
We determine the most popular genre as the genre with the highest
amount of purchases. Write a query that returns each country along with
the top Genre. For countries where the maximum number of purchases*/
is shared return all genres.

with popular_genre as
(
	select count(invoice_line.quantity)as purchases, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1

/*Q3: Write a query that determines the customer that has spent the most
on music for each country. Write a wuery that returns the country along
with the top customer and how much they spent. For countries where
the top amount spent i shared, provide all customers who spent this amount*/

with recursive
	customer_with_country as (
		select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 2,3 desc),

	country_max_spending as(
		select billing_country, max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)

select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;