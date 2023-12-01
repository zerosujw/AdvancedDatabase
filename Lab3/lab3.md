## Part 1

Create users:

```postgresql
CREATE USER inventory_manager;
CREATE USER order_packer1;
CREATE USER order_packer2;
```

Create roles:

```postgresql
CREATE ROLE inventory_role;
CREATE ROLE orderView_role;
```

Grant roles to users:

```postgresql
GRANT inventory_role to inventory_manager;
GRANT orderView_role to order_packer1, order_packer2;
```

## Part 2

Grant privileges to roles:

```postgresql
GRANT SELECT, UPDATE ON "Products" TO inventory_role;
GRANT SELECT ON "OrderDetails" TO orderView_role;
```

### Least-privilege

The principle of least-privilege is only providing users minimal access or permissions necessary to complete their tasks.
It is crucial for database security because it can minimize attack surface, reduce insider threats, prevent unauthorized access and mitigate the risk of data breaches.

## Part 3

Create a table:

```postgresql
CREATE TABLE packer_assignment
(
	order_id INTEGER,
	packer_name TEXT,
	FOREIGN KEY (order_id) REFERENCES "Orders"
);
```

Fill the table:

```postgresql
INSERT INTO packer_assignment
VALUES
	(1, 'order_packer1'),
	(2, 'order_packer2'),
	(3, 'order_packer1');
```

Enable row level security:

```postgresql
ALTER TABLE packer_assignment
ENABLE ROW LEVEL SECURITY;
```

Create policy on this table that only allows users with the same name as `packer_name` attribute access this record:

```postgresql
CREATE POLICY packer_policy
ON packer_assignment
TO orderView_role
USING (packer_name = CURRENT_USER)
```

Grant the select privilege to `orderView_role`:
This is necessary. If we don't do this, packers won't be able to access the `packer_assignment` table at all.

```postgresql
GRANT SELECT ON TABLE packer_assignment TO orderView_role;
```

Test the validity of row level security:

```postgresql
SET ROLE order_packer2;
SELECT * FROM packer_assignment;
```

![](Pasted%20image%2020231129085947.png)
`order_packer2` cannot access orders assigned to `order_packer1` (order1 and order3).

## Part 4

Install extension:

```postgresql
CREATE EXTENSION IF NOT EXISTS pgcrypto
```

Add a column in `Consumers`:
The type of `encrypted_email` must be `bytea` or you won't be able to decrypt it.

```postgresql
ALTER TABLE "Consumers"
ADD COLUMN encrypted_email BYTEA;
```

Generate a key randomly:

```postgresql
SELECT encode(gen_random_bytes(32), 'hex') AS encryption_key;
```

```
3d36a3d495b30c4885182925bc20267eb8f3c804f786dfecb9e3e2ede4476078
```

Encrypt emails using the key and update the table:

```postgresql
UPDATE "Consumers"
SET encrypted_email = pgp_sym_encrypt(email, '3d36a3d495b30c4885182925bc20267eb8f3c804f786dfecb9e3e2ede4476078');
```

![](Pasted%20image%2020231129092746.png)
The type of `encrypted_email` was set to `text` by mistake. But it has been changed to `bytea`.

Try to decrypt the data:

```postgresql
SELECT pgp_sym_decrypt(encrypted_email, '3d36a3d495b30c4885182925bc20267eb8f3c804f786dfecb9e3e2ede4476078')
FROM "Consumers";
```

![](Pasted%20image%2020231129130836.png)

Drop original `email` column:

```postgresql
ALTER TABLE "Consumers"
DROP COLUMN email;
```

![](Pasted%20image%2020231129131200.png)

### Least-privilege

In [Part 2](#Part%202)
