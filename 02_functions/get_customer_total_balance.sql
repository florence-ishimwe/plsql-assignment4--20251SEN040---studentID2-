CREATE OR REPLACE FUNCTION get_customer_total_balance (
    p_customer_id IN bank_customers.customer_id%TYPE
) RETURN NUMBER IS
    v_total_balance     NUMBER(12, 2) := 0;
    v_customer_exists   NUMBER;
BEGIN
    -- Verify if customer exists
    SELECT COUNT(*) INTO v_customer_exists 
    FROM bank_customers 
    WHERE customer_id = p_customer_id;

    IF v_customer_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: Customer ID ' || p_customer_id || ' does not exist.');
    END IF;

    -- Calculate total balance
    SELECT NVL(SUM(balance), 0)
    INTO v_total_balance
    FROM bank_accounts
    WHERE customer_id = p_customer_id AND status = 'ACTIVE';

    RETURN v_total_balance;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20099, 'Error calculating total balance: ' || SQLERRM);
END get_customer_total_balance;
/
