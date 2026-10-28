CREATE OR REPLACE PROCEDURE process_transaction (
    p_account_id IN bank_accounts.account_id%TYPE,
    p_type       IN bank_transactions.transaction_type%TYPE,
    p_amount     IN bank_transactions.amount%TYPE
) IS
    v_current_balance   bank_accounts.balance%TYPE;
    e_insufficient_funds EXCEPTION;
    e_invalid_type      EXCEPTION;
BEGIN
    -- Check amount validity
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Transaction amount must be greater than zero.');
    END IF;

    -- Check transaction type
    IF p_type NOT IN ('DEPOSIT', 'WITHDRAWAL') THEN
        RAISE e_invalid_type;
    END IF;

    -- Lock and fetch current balance
    SELECT balance INTO v_current_balance
    FROM bank_accounts
    WHERE account_id = p_account_id AND status = 'ACTIVE'
    FOR UPDATE;

    -- Process withdrawal or deposit
    IF p_type = 'WITHDRAWAL' THEN
        IF v_current_balance < p_amount THEN
            RAISE e_insufficient_funds;
        END IF;

        UPDATE bank_accounts
        SET balance = balance - p_amount
        WHERE account_id = p_account_id;
    ELSIF p_type = 'DEPOSIT' THEN
        UPDATE bank_accounts
        SET balance = balance + p_amount
        WHERE account_id = p_account_id;
    END IF;

    -- Log successful transaction
    INSERT INTO bank_transactions (account_id, transaction_type, amount, status)
    VALUES (p_account_id, p_type, p_amount, 'SUCCESS');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE(p_type || ' transaction successful for account ' || p_account_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Account not found or inactive.');
    WHEN e_insufficient_funds THEN
        ROLLBACK;
        INSERT INTO bank_transactions (account_id, transaction_type, amount, status, error_message)
        VALUES (p_account_id, p_type, p_amount, 'FAILED', 'Insufficient funds');
        COMMIT;
        RAISE_APPLICATION_ERROR(-20005, 'Transaction failed: Insufficient funds.');
    WHEN e_invalid_type THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Invalid transaction type. Use DEPOSIT or WITHDRAWAL.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20099, 'Transaction error: ' || SQLERRM);
END process_transaction;
/
