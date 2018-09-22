#!/usr/bin/wish

sqlite3 db ./phraseMapper.db 

db eval {
    CREATE TABLE IF NOT EXISTS Fragment (
    Id INT NOT NULL AUTO_INCREMENT,
    Text TEXT,
    Language TEXT,

    PRIMARY KEY Id)
}

db eval {
    CREATE TABLE IF NOT EXISTS Text (
        Id INT NOT NULL AUTO_INCREMENT,
        Name TEXT,

        PRIMARY KEY(Id))
}

db eval {
    CREATE TABLE IF NOT EXISTS Fragment2Text (
        Id INT NOT NULL AUTO_INCREMENT,
        Order1 INT,
        Order2 INT,
        Fragment INT,
        Text TEXT,
        

        PRIMARY KEY(Id),
        FOREIGN KEY(Fragment) REFERENCES Fragment(Id),
        FOREIGN KEY(Text) REFERENCES Text(Id),
}

oo::class create Text{
    constructor {} {
        variable Fragments
        variable Language
    }
}

oo::class create Fragment {
    constructor {} {
        variable Text
        variable Language
        variable Translation
    }
}
