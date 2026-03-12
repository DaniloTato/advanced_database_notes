--5. Try It!

--1
select colour from my_brick_collection
union
select colour from your_brick_collection
order by colour;

--2
select shape from my_brick_collection
union all
select shape from your_brick_collection
order  by shape;





--10. Try It!

--1
SELECT shape FROM my_brick_collection
minus
SELECT shape FROM your_brick_collection;

--2
select colour from my_brick_collection
intersect
select colour from your_brick_collection
order  by colour;

