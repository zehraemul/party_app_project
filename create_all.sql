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
	oEventID INT2 NOT NULL,
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

		
--insert to tables
--id yok
INSERT INTO users (userName, password, firstName, lastName, phoneNumber) VALUES
('melihtuna', 'melih', 'Melih', 'Ipek', '1234567890'),
('zehraemul', 'zehra', 'Zehra', 'Emul', '9876543210'),
('omeraskin', 'omer', 'Omer', 'Askin', '5555555555'),
('ozlemkoc', 'ozlem', 'Ozlem', 'Koc', '4444444444'),
('aysenazkonan', 'aysenaz', 'Aysenaz', 'Konan', '6666666666'),
('mudaferkaymak', 'mudafer', 'Mudafer', 'Kaymak', '7777777777'),
('emiroguz', 'emir', 'Emir', 'Oguz', '8888888888'),
('fatihakkus', 'fatih', 'Fatih', 'Akkus', '9999999999'),
('abdullahbelikirik', 'abdullah', 'Abdullah', 'Belikirik', '1111111111'),
('ezgisevi', 'ezgi', 'Ezgi', 'Sevi', '2222222222'),
('ibrahimsahin', 'ibrahim', 'Ibrahim', 'Sahin', '3333333333');
select * from users;
--id var
INSERT INTO eventAddresses (addressid,addressname) VALUES
(1,'Ev1(Taksim)'),
(2,'Ev2(Besiktas)'),
(3,'Yat'),
(4,'Tekne'),
(5,'Restaurant1(Bebek)'),
(6,'Restaurant2(Sariyer)'),
(7,'Restaurant3(Uskudar)'),
(8,'Hotel1(Buyukada)'),
(9,'Hotel2(Aksaray)'),
(10,'Hotel3(Levent)'),
(11,'Acik Alan1(Beykoz)'),
(12,'Acik Alan2(Maltepe)');

select * from eventAddresses;
--id var
INSERT INTO eventTypes (typeid,typeName) VALUES
(1,'Yilbasi Kutlamalari'),
(2,'Dogumgunu'),
(3,'Dugun'),
(4,'Kina'),
(5,'Bekarliga Veda'),
(6,'Baby Shower'),
(7,'Ramazan Etkinligi'),
(8,'Acilis Daveti'),
(9,'Konser'),
(10,'Lansman Organizasyonu'),
(11,'Mezuniyet'),
(12,'Sirket Yemegi');

select * from eventTypes;

--id yok
INSERT INTO events (eventName, eventType, eventQuota, eventAddress, eventPrice, eventSeason, eventStock) VALUES
('Event1', 1, 500, 10, 50.00, 'Kis', 20),
('Event2', 2, 100,4, 15.00, 'Ilkbahar', 15),
('Event3', 3, 800,11, 300.00, 'Yaz', 25),
('Event4',4, 400, 9, 75.00, 'Ilkbahar', 15),
('Event5', 5, 300, 3, 20.00, 'Yaz', 20),
('Event6', 6, 100,12, 20.00, 'Sonbahar', 25),
('Event7', 7, 2000, 7, 30.00, 'Ilkbahar', 20),
('Event8', 8, 600, 4, 40.00, 'Kis', 20),
('Event9',9, 1200, 12, 100.00, 'Yaz', 15),
('Event10', 10, 1000, 1, 50.00, 'Kis', 25),
('Event11', 11, 5000, 3, 40.00, 'Yaz', 10),
('Event12', 12, 900, 6, 10.00, 'Yaz', 5);

select * from events;

--id yok
INSERT INTO extras ( extraname,extraprice, extranumberofpieces) VALUES
('Masa', 2.00, 500),
('Sandalye', 2.00, 500),
('Hoporler', 15.00, 50),
('Cicek', 5.00, 300),
('Masa Ortusu', 4.00, 100),
('Fotograf Makinesi', 25.00, 100),
('Yas Pasta', 5.00, 100),
('Bardak', 1.00, 800),
('Tabak', 1.00, 800),
('Palyaco', 15.00, 400),
('Dansci', 15.00, 200);

select * from extras;
--id yok
INSERT INTO offers (ouserid, oeventid,oextraid) VALUES
(2, 13 , 2 ),
(3, 14, 3),
(4, 15, 4),
(5, 16, 5),
(6, 17, 6),
(7, 18, 7),
(8, 19, 8),
(9, 20, 9),
(10, 21, 10),
(11, 22, 11),
(2, 23, 12);

select * from offers;


























		