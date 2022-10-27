-- =====================================================================================
-- (H2) Table setup script for the IDS Connector test database.
-- =====================================================================================
drop schema if exists connector;
create schema connector;

-- =====================================================================================
-- CATEGORY stores categories.
-- =====================================================================================
create table connector.CATEGORY (  
    id              identity primary key,        -- KEY (database-assigned ID)
    
   name         varchar(30) not null unique,   -- Category names such as 'Document', 'Package', etc 
    description       varchar(255)               -- A description of the category.
);

-- =====================================================================================
-- STATE stores information about states for things such as Packages, Documents, etc.
-- =====================================================================================
create table connector.STATE (  
    id              identity primary key,     -- KEY (database-assigned ID)
    
    category_id       bigint not null,         -- FK, ID of a Category such as 'Package', 'Document', etc.
    name         varchar(30) not null,     -- Names such as 'Received', 'Delivered', etc. depending on the category.
                                        -- See insertSeedData.sql for actual values.
    description       varchar(255),           -- A description of the state.
    
   constraint State_CategoryId_fk foreign key (category_id)   references connector.CATEGORY (id),
   constraint State_CategoryName_unique unique(category_id, name)
);

-- =====================================================================================
-- DOCUMENT holds the contents and some metadata about incoming documents, that is, Documents 
-- that were *received* by Connector from Hub.
-- =====================================================================================
create table connector.DOCUMENT (
   id              char(50) primary key,  -- KEY (application-assigned, UUID) Document ID.  The document IDs (UUIDs) are
                                    -- assigned by the Hub when it creates OutDocument records, and these same
                                    -- IDs are used by the connector when it receives Documents from the hub.
   doctype          varchar(30) ,  -- The type of document (such as 'Invoice', 'Remittance', etc.)
    format             varchar(30) ,  -- The document format, such as 'EDI810', 'Lawson', 'cXML', 'L8MA540', 'PDF', etc.
    encoding        varchar(30) ,  -- The document encoding, such as 'Text', 'Base64', etc.
    filename        varchar(255),        -- The document filename.

    contents      longblob ,    -- The document's full contents
    
    state_id      bigint not null,      -- FK (ID of a STATE row that represents the document's current state)
                                     -- Used to track the process of receving and delivering the document to the target system.
    receiver_id       varchar(36) not null,     -- External ID (e.g. 'P00001') of the participant receiving this document.
    attempts      int,               -- Stores the number of times that a given step in 'receive, deliver and acknowledge' process has failed for
                                     -- this document.  Each time a step is successfully completed, this count is reset to 0.
    next_attempt   datetime,           -- Date and time at which delivery will be reattempted for this document. 
    
    last_modified  datetime,           -- Date and time of the last modification on this document. 

    constraint  Document_StateId_fk       foreign key (state_id)        references connector.STATE (id)
);

-- =====================================================================================
-- PACKAGE holds the contents and some metadata about outgoing Packages, that is, Packages 
-- that are being *submitted* (sent) by Connector to the Hub.
-- =====================================================================================
create table connector.PACKAGE (
   id              char(50) primary key,  -- KEY (application-assigned, UUID) Package ID.  The package IDs (UUIDs) are
                                    -- assigned by the connector when it first receives a package from some
                                    -- PackageSource (ERP system, file-system drop-zone, etc.)
   sender_id     char(36) not null,        -- External ID (e.g. 'P00001') of the participant that submitted this package
   pkgtype          varchar(30) not null,  -- The type of package (such as 'Invoice', 'Remittance', etc.)
    format             varchar(30) not null,  -- The package format, such as 'EDI810', 'Lawson', 'cXML', 'L8MA540', 'PDF', etc.
    encoding        varchar(30) not null,  -- The package encoding, such as 'Text', 'Base64', etc.
   filename      varchar(512),        -- Stores the filename, if any, from which this Package was obtained.
                                    -- In the case where a package was obtained from a non-file-system PackageSource
                                    -- (such as a DatabasePackageSource, etc.) then the filename will be null.
   contents      longblob not null,    -- The package's full contents
    
    state_id      bigint not null,      -- FK (ID of a STATE row that represents the package's current state)
                                     -- Used to track the process of submitting the package to the IDS Hub.
    attempts      int,               -- -- Stores the number of times that a given step in 'submit package to hub' process has failed for
                                     -- this package.  Each time a step is successfully completed, this count is reset to 0. 
    next_attempt   datetime,           -- Date and time at which delivery will be reattempted for this package.
    
    constraint  Package_StateId_fk        foreign key (state_id)        references connector.STATE (id)
);

-- =====================================================================================
-- PACKAGE holds the contents and some metadata about outgoing Packages, that is, Packages 
-- that are being *submitted* (sent) by Connector to the Hub.
-- =====================================================================================
create table connector.ERROR_LOG (
   id              identity primary key,        -- KEY (database-assigned ID)
   level        varchar(10) not null,  -- Level of the error message (WARN, ERROR, FATAL)
    message            varchar(1500) not null,    -- The error message
    dateTime      datetime,           -- Date and time at which the error occured. 
    sent           boolean not null   -- Flag indicating whether or not this error has been sent to the hub.
);

create table connector.PATCH (
    id                 char(36) not null primary key, -- KEY (application-assigned, UUID) Connector Update ID
   
   last_modified     timestamp not null,          -- Date and time of the last state change for the PATCH
   state_id         bigint not null,         -- FK (ID of a PATCH that represents the patch's current state)
   state_reported    boolean not null         -- Flag indicating if the status of this update has been sent to the hub.
);

-- =====================================================================================
-- V_DOCUMENT
-- =====================================================================================
create view connector.V_DOCUMENT as 
  select 
    d.id, 
    s.name state, 
    d.doctype type,
    d.format,
    d.encoding, 
    d.filename, 
    d.attempts, 
    d.next_attempt,
    d.last_modified
  from connector.DOCUMENT d, connector.STATE s
  where d.state_id = s.id;
  
-- =====================================================================================
-- V_PACKAGE
-- =====================================================================================
create view connector.V_PACKAGE as 
  select 
    p.id, 
    s.name state, 
    p.pkgtype type, 
    p.format, 
    p.encoding, 
    p.filename, 
    p.attempts, 
    p.next_attempt
  from connector.PACKAGE p, connector.STATE s
  where p.state_id = s.id;
  
