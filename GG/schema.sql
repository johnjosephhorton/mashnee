DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS urls;
DROP TABLE IF EXISTS properties; 

CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  property_name TEXT NOT NULL
);


CREATE TABLE urls (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  url TEXT NOT NULL,
  order_id INTEGER NOT NULL, 
  FOREIGN KEY (order_id) REFERENCES orders (id)	
);

CREATE TABLE properties (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  url_id INTEGER NOT NULL,
  address TEXT,
  square_feet INTEGER,
  bedrooms FLOAT,
  baths FLOAT,
  price INTEGER,
  comp BOOLEAN,
  order_id INTEGER, 
  FOREIGN KEY (url_id) REFERENCES urls (id),	
  FOREIGN KEY (order_id) REFERENCES orders (id)	
); 

 -- CREATE TABLE post (
--   id INTEGER PRIMARY KEY AUTOINCREMENT,
--   author_id INTEGER NOT NULL,
--   created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--   title TEXT NOT NULL,
--   body TEXT NOT NULL,
--   
-- );
