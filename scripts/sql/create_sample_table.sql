CREATE TABLE SampleTable (
    Id INT PRIMARY KEY,
    Nome NVARCHAR(100),
    Email NVARCHAR(100),
    DataCriacao DATETIME DEFAULT GETDATE()
);

INSERT INTO SampleTable (Id, Nome, Email)
VALUES (1, 'Sergio', 'sergio@example.com'),
       (2, 'Maria', 'maria@example.com'),
       (3, 'João', 'joao@example.com');
