-- Stored Procedure to compute the average amount of products of a brand
-- and update the quantity in save_to_shopping_cart relation
CREATE OR REPLACE FUNCTION func1(vpid INTEGER, vbrand VARCHAR) RETURNS INTEGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_amount INTEGER;
BEGIN
    SELECT AVG(amount) INTO v_amount FROM product WHERE brand = vbrand;
    
    UPDATE save_to_shopping_cart SET quantity = v_amount WHERE pid = vpid;
    
    RETURN v_amount;
END;
$$;

-- Execute the stored procedure
SELECT func1(8, 'Microsoft');

-- Recover by resetting quantity for pid = 8
UPDATE save_to_shopping_cart SET quantity = 1 WHERE pid = 8;

-- Trigger Procedure for auditing quantity changes in shopping cart
CREATE TABLE IF NOT EXISTS shoppingcart_audits (
    id SERIAL PRIMARY KEY,
    userid INT NOT NULL,
    pid INT NOT NULL,
    quantity INT NOT NULL,
    changed_on TIMESTAMP(6) NOT NULL
);

CREATE OR REPLACE FUNCTION shoppingcart_quantity_changes()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantity <> OLD.quantity THEN
        INSERT INTO shoppingcart_audits (userid, pid, quantity, changed_on)
        VALUES (OLD.userid, OLD.pid, OLD.quantity, now());
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER quantity_changes
    BEFORE UPDATE ON save_to_shopping_cart
    FOR EACH ROW
    EXECUTE FUNCTION shoppingcart_quantity_changes();
