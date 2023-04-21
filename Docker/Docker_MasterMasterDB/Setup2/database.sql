CREATE TABLE Media (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    descr TEXT,
    cover VARCHAR(255),
    average_score FLOAT,
    release_date DATE,
    media_type ENUM('Movie', 'Series'),
    youtube_trailer VARCHAR(255)
);
