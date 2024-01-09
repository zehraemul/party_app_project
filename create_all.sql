-- sequences
CREATE SEQUENCE user_sequence
START 1
INCREMENT 1;

CREATE SEQUENCE event_sequence
START 1
INCREMENT 1;

CREATE SEQUENCE offer_sequence
START 1
INCREMENT 1;

CREATE SEQUENCE extra_sequence
START 1
INCREMENT 1;

-- tables
CREATE TABLE users (
	userID INT2 DEFAULT nextval('user_sequence') PRIMARY KEY,
    userName VARCHAR(32) NOT NULL,
    password VARCHAR(32) NOT NULL,
    firstName VARCHAR(32) NOT NULL,
	lastName VARCHAR(32),
    phoneNumber VARCHAR(11)
);

CREATE TABLE eventAddresses (
	addressID INT2 PRIMARY KEY,
	addressName VARCHAR(255) NOT NULL
);

CREATE TABLE eventTypes (
	typeID INT2 PRIMARY KEY,
	typeName VARCHAR(255) NOT NULL
);

CREATE TABLE events (
	eventID INT2 DEFAULT nextval('event_sequence') PRIMARY KEY,
    eventName VARCHAR(32) NOT NULL,
    eventType INT2 NOT NULL,
    eventQuota INT2 NOT NULL,
	eventAddress INT2 NOT NULL,
    eventPrice NUMERIC(9,2) NOT NULL,
	eventSeason VARCHAR(32) NOT NULL,
	eventStock INT2 DEFAULT 10,
	CONSTRAINT fk_address
		FOREIGN KEY (eventAddress)
			REFERENCES eventAddresses (addressID)
			ON DELETE CASCADE,
	CONSTRAINT fk_type
		FOREIGN KEY (eventType)
			REFERENCES eventTypes (typeID)
			ON DELETE CASCADE
);

CREATE TABLE extras (
	extraID INT2 DEFAULT nextval('extra_sequence') PRIMARY KEY,
    extraName VARCHAR(32) NOT NULL,
	extraPrice NUMERIC(9,2) NOT NULL,
	extraNumberOfPieces INT2 NOT NULL
);

CREATE TABLE offers (
	offerID INT2 DEFAULT nextval('offer_sequence') PRIMARY KEY,
    oUserID INT2 NOT NULL,
	oEventID INT2,
	oExtraID INT2,
	CONSTRAINT fk_user
		FOREIGN KEY (oUserID)
			REFERENCES users (userID)
			ON DELETE CASCADE,
	CONSTRAINT fk_event
		FOREIGN KEY (oEventID)
			REFERENCES events (eventID)
			ON DELETE CASCADE,
	CONSTRAINT fk_extra
		FOREIGN KEY (oExtraID)
			REFERENCES extras (extraID)
			ON DELETE CASCADE
);

-- trigger functions
CREATE FUNCTION user_register_trig_func()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (
		SELECT 1 FROM users
		WHERE userName = NEW.userName
	) THEN
			RAISE EXCEPTION 'Kullanıcı adı % zaten mevcut.', NEW.userName;
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER user_register_trig
BEFORE INSERT ON users
FOR EACH ROW EXECUTE PROCEDURE user_register_trig_func();


CREATE FUNCTION add_event_trig_func()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM events 
        WHERE eventName = NEW.eventName 
          AND eventType = NEW.eventType 
          AND eventQuota = NEW.eventQuota 
          AND eventAddress = NEW.eventAddress 
          AND eventPrice = NEW.eventPrice 
          AND eventSeason = NEW.eventSeason
    ) THEN
        RAISE EXCEPTION 'Etkinlik zaten mevcut.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER add_event_trigger
BEFORE INSERT ON events 
FOR EACH ROW EXECUTE PROCEDURE add_event_trig_func();


-- view 
CREATE VIEW displayEvents AS
SELECT 
    e.eventName as "Name",
    t.typeName as "Type",
    a.addressName as "Address",
    e.eventPrice as "Price",
    e.eventSeason as "Season"
FROM 
    events e
    INNER JOIN eventAddresses a ON e.eventAddress = a.addressID
    INNER JOIN eventTypes t ON e.eventType = t.typeID;

		
--
		