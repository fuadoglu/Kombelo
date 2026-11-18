-- PostgreSQL reference schema. Apply as a versioned migration in implementation.
CREATE TABLE players (
  id uuid PRIMARY KEY, auth_subject text NOT NULL UNIQUE,
  public_code text NOT NULL UNIQUE CHECK (public_code ~ '^[A-Z0-9]{8}$'),
  nickname text NOT NULL, country text CHECK (country ~ '^[A-Z]{2}$'),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE boards (
  id text PRIMARY KEY, opens_at timestamptz NOT NULL, closes_at timestamptz NOT NULL,
  rules_version integer NOT NULL CHECK (rules_version > 0), digest text NOT NULL CHECK (digest ~ '^[0-9a-f]{64}$'),
  payload jsonb NOT NULL, status text NOT NULL CHECK (status IN ('scheduled','published','void')),
  CHECK (opens_at < closes_at)
);
CREATE TABLE attempts (
  id uuid PRIMARY KEY, player_id uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  board_id text NOT NULL REFERENCES boards, slot smallint NOT NULL CHECK (slot BETWEEN 1 AND 2),
  idempotency_key text NOT NULL, country_snapshot text, created_at timestamptz NOT NULL DEFAULT now(),
  submitted_at timestamptz, score integer CHECK (score >= 0), move_digest text, moves jsonb,
  UNIQUE (player_id, board_id, slot), UNIQUE (player_id, board_id, idempotency_key),
  CHECK ((score IS NULL AND submitted_at IS NULL AND move_digest IS NULL AND moves IS NULL)
      OR (score IS NOT NULL AND submitted_at IS NOT NULL AND move_digest IS NOT NULL AND moves IS NOT NULL))
);
CREATE INDEX attempts_rank ON attempts (board_id, score DESC, player_id) WHERE score IS NOT NULL;
CREATE TABLE friend_invites (
  id uuid PRIMARY KEY, sender uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  recipient uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  accepted_at timestamptz, created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (sender, recipient), CHECK (sender <> recipient)
);
CREATE TABLE player_blocks (
  blocker uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  blocked uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  PRIMARY KEY (blocker, blocked), CHECK (blocker <> blocked)
);
CREATE TABLE devices (
  player_id uuid NOT NULL REFERENCES players ON DELETE CASCADE, id uuid NOT NULL,
  locale text NOT NULL, zone text NOT NULL, token text UNIQUE,
  push_daily boolean NOT NULL DEFAULT false, push_friends boolean NOT NULL DEFAULT false,
  PRIMARY KEY (player_id, id)
);
CREATE TABLE nickname_reports (
  reporter uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  reported uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  nickname_snapshot text NOT NULL, reason text NOT NULL,
  state text NOT NULL DEFAULT 'pending' CHECK (state IN ('pending','dismissed','resolved')),
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (reporter, reported, nickname_snapshot), CHECK (reporter <> reported)
);
CREATE TABLE weekly_country (
  week_start date NOT NULL, player_id uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  country text CHECK (country ~ '^[A-Z]{2}$'), PRIMARY KEY (week_start, player_id)
);
CREATE TABLE operations_audit (
  id uuid PRIMARY KEY, operation text NOT NULL, operator_subject text NOT NULL,
  reason text NOT NULL, detail jsonb NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE notification_outbox (
  id uuid PRIMARY KEY, player_id uuid NOT NULL REFERENCES players ON DELETE CASCADE,
  kind text NOT NULL, dedupe_key text NOT NULL UNIQUE, earliest_at timestamptz NOT NULL,
  expires_at timestamptz NOT NULL, sent_at timestamptz, CHECK (earliest_at < expires_at)
);
