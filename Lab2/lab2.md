## Part 1

Empty `Consumers` table. Disable trigger to prevent errors caused by foreign key constrain.

```postgresql
ALTER TABLE "Consumers" DISABLE TRIGGER ALL;
DELETE FROM "Consumers";
ALTER TABLE "Consumers" ENABLE TRIGGER ALL;
```

Refill the `Consumers` table with a transaction:

```postgresql
BEGIN;
INSERT INTO "Consumers"
VALUES
	(1, 'Abby', 'Abby@gmail.com', 'Berlin'),
	(2, 'Bob', 'Bob@hotmail.com', 'Munchen'),
	(3, 'Carl', 'Carl@yahoo.com', 'Achen'),
	(4, 'Darlin', 'Darlin@apple.com', 'Sarrland'),
	(5, 'Ela', 'Ela@mit.com', 'Dusseldurf'),
	(6, 'Finka', 'Finka@openai.com', 'Bremen');
COMMIT;
```

## Part 2

Print a table:

```postgresql
SELECT * FROM "Products";
```

![](Pasted%20image%2020231125153722.png)

Insert using a transaction:

```postgresql
BEGIN;
INSERT INTO "Products"
VALUES
	(6, 'Portal', 12);
INSERT INTO "Products"
VALUES
	(1, 'Metal Gear', 50);
```

Because the second insertion has a primary key that already exists in the table, an error happened, says the unique constrain is violated.

And if we try to execute another query, there will be another error says that the transaction is terminated and queries are ignored.

Revert the transaction:

```postgresql
ROLLBACK;
```

Print the content again:

```postgresql
SELECT * FROM "Products";
```

![](Pasted%20image%2020231125153722.png)
The result after rolling back is exactly the same as this table before the transaction.

### Using savepoints

Begin a transaction, insert a valid record and create a savepoint called `inserPoint`:

```postgresql
BEGIN;
INSERT INTO "Products"
VALUES
	(6, 'Portal', 12);
SAVEPOINT inserPoint;

```

Insert a invalid record:

```postgresql
INSERT INTO "Products"
VALUES
	(1, 'Metal Gear', 50);
```

Same error occurred saying key value already exists.

Revert the transaction to `inserPoint`:

```postgresql
ROLLBACK TO inserPoint;
```

Print the table:

```postgresql
SELECT * FROM "Products"
```

![](Pasted%20image%2020231125153644.png)
There is one more record in the table comparing to the table at the beginning.
It appears that the first insertion is done.

Insert a new valid row and commit changes:

```postgresql
INSERT INTO "Products"
VALUES
	(7, 'The Witcher', 12);
COMMIT;
```

![](Pasted%20image%2020231125153615.png)

## Part 3

Create `order_audit` table:

```postgresql
CREATE TABLE order_audit
(
    audit_id SERIAL PRIMARY KEY,
    operation CHAR(1),
    order_id INTEGER,
    audit_timestamp TIMESTAMP
);
```

Create a trigger function that logs orders to `order_audit`:

```postgresql
CREATE OR REPLACE FUNCTION log_new_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO "order_audit"(operation, order_id, audit_timestamp)
    VALUES ('I', NEW.order_id, CURRENT_TIMESTAMP);
    RETURN NEW;
END
$$ LANGUAGE plpgsql;
```

`NEW` refers to the record we received from the original insertion. We can use it to access the original tuple. And it must be returned.

We can specify the name of the returned trigger like `$trigger_name$`. But here we just leave it empty.

It seems that the language should be `plpgsql` rather than `sql`. Or there will be an error.

Create a trigger using the trigger function above:

```postgresql
CREATE TRIGGER orders_after_insert
AFTER INSERT ON "Orders"
FOR EACH ROW
EXECUTE FUNCTION log_new_order();
```
## Part 4

Insert a new order in the `Orders` table.

```postgresql
INSERT INTO "Orders"
VALUES
    (13, 6, '2023-12-12');
```

Print `order_audit` table.

```sql
SELECT * FROM order_audit;
```

![](Pasted%20image%2020231125153507.png)
The trigger is functional.


Create a trigger to prevent the insertion of products that do not exist into the OrderDetails table:

We can either delete the inserted records after insertion or take over the insertion. Like this:

```postgresql
CREATE OR REPLACE FUNCTION prevent_phantom_product()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.product_id NOT IN (SELECT product_id FROM "Products") THEN
        RAISE EXCEPTION 'Product does not exist.';

        DELETE FROM "OrderDetails"
        WHERE product_id = NEW.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_details_after_insert
AFTER INSERT ON "OrderDetails"
FOR EACH ROW
EXECUTE FUNCTION prevent_phantom_product()
```

Let's try to insert a order detail with a non-exist product (id=99):

```sql
INSERT INTO "OrderDetails"
VALUES (
	25, 12, 99, 3
)
```

But it turns out that the trigger which does exactly the same thing has already existed.
It could be created along with the foreign key constraint of `OrderDetails` table, since `product_id` is a foreign key.

![](Pasted%20image%2020231127084022.png)
Our attempt to insert will be interrupted by this trigger first.

