-- Run after schema.sql in a disposable database. Leave fixture data untouched.
BEGIN;
INSERT INTO players (id, auth_subject, public_code, nickname)
VALUES ('00000000-0000-0000-0000-000000000001', 'fixture', 'PLAY0001', 'Fixture');
INSERT INTO boards (id, opens_at, closes_at, rules_version, digest, payload, status)
VALUES ('fixture', now(), now() + interval '1 hour', 1, repeat('0', 64), '{}', 'published');
DO $$
BEGIN
  INSERT INTO attempts (id, player_id, board_id, slot, idempotency_key)
  VALUES ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'fixture', 1, 'first');
  BEGIN
    INSERT INTO attempts (id, player_id, board_id, slot, idempotency_key)
    VALUES ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'fixture', 2, 'first');
    RAISE EXCEPTION 'reused attempt key was accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    INSERT INTO attempts (id, player_id, board_id, slot, idempotency_key)
    VALUES ('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'fixture', 1, 'different');
    RAISE EXCEPTION 'occupied attempt slot was accepted';
  EXCEPTION WHEN unique_violation THEN NULL;
  END;
  BEGIN
    UPDATE attempts SET score = 100 WHERE board_id = 'fixture';
    RAISE EXCEPTION 'partial result was accepted';
  EXCEPTION WHEN check_violation THEN NULL;
  END;
END $$;
DELETE FROM players WHERE auth_subject = 'fixture';
DO $$
BEGIN
  IF EXISTS (SELECT FROM attempts WHERE board_id = 'fixture') THEN
    RAISE EXCEPTION 'account deletion left an attempt';
  END IF;
END $$;
ROLLBACK;
