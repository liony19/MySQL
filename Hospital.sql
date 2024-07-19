USE master;
IF DB_ID('Hospital') IS NOT NULL
    DROP DATABASE Hospital;
CREATE DATABASE Hospital;
GO
USE Hospital;

CREATE TABLE Paciente
(
    CPF CHAR(11) PRIMARY KEY NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Telefone VARCHAR(15) NOT NULL,
    Email VARCHAR(30) UNIQUE NOT NULL,
    Logradouro VARCHAR(50) NOT NULL,
    Numero VARCHAR(10) NOT NULL,
    Complemento VARCHAR(30),
    CEP CHAR(9) NOT NULL,
    Bairro VARCHAR(30) NOT NULL,
    Cidade VARCHAR(30) NOT NULL,
    Estado CHAR(2) NOT NULL,
    CONSTRAINT chk_estado CHECK (Estado IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO')),
    CONSTRAINT chk_cep CHECK (CEP LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]')
);
CREATE UNIQUE INDEX idx_paciente_cpf ON Paciente(CPF);

CREATE TABLE Convenio
(
    Nome VARCHAR(50) NOT NULL,
    CNPJ VARCHAR(20) PRIMARY KEY NOT NULL,
    Tempo_Carencia VARCHAR(7) NOT NULL,
    CONSTRAINT chk_tempo_carencia CHECK (Tempo_Carencia LIKE '[0-9][0-9] Dias')
);

CREATE TABLE Paciente_Convenio
(
    CPF_Paciente CHAR(11) REFERENCES Paciente(CPF)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    CNPJ_Convenio VARCHAR(20) REFERENCES Convenio(CNPJ)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    PRIMARY KEY (CPF_Paciente, CNPJ_Convenio)
);

CREATE TABLE Avaliacao_Medica
(
    Cod_Procedimento INT PRIMARY KEY NOT NULL,
    Exame VARCHAR(50) NOT NULL
);

CREATE TABLE Paciente_Avaliacao
(
    CPF_Paciente CHAR(11) REFERENCES Paciente(CPF)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Cod_Procedimento INT REFERENCES Avaliacao_Medica(Cod_Procedimento)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    PRIMARY KEY (CPF_Paciente, Cod_Procedimento)
);

CREATE TABLE Medico 
( 
    Cod_CRM CHAR(9) PRIMARY KEY NOT NULL,
    Especialidade VARCHAR(20) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    Telefone VARCHAR(15) NOT NULL,
    CPF CHAR(11) NOT NULL
);

CREATE UNIQUE INDEX idx_medico_cod_crm ON Medico(Cod_CRM);

CREATE TABLE Consulta
(
    ID_Consulta INT PRIMARY KEY NOT NULL,
    Cod_CRM CHAR(9) REFERENCES Medico(Cod_CRM)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Nome_Medico VARCHAR(50) NOT NULL,
    CPF_Paciente CHAR(11) REFERENCES Paciente(CPF)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Nome_Paciente VARCHAR(50) NOT NULL,
    Especialidade_Medico VARCHAR(20) NOT NULL,
    Valor_Consulta MONEY DEFAULT (500) NOT NULL,
    Data_Consulta DATE NOT NULL,
    Hora_Consulta TIME NOT NULL,
    CONSTRAINT chk_valor_consulta CHECK (Valor_Consulta > 0),
    CONSTRAINT chk_data_consulta CHECK (Data_Consulta >= CAST(GETDATE() AS DATE))
);

CREATE INDEX idx_Data_Consulta ON Consulta(Data_Consulta);

CREATE TABLE Receita_Medica
(
    ID_Receita INT PRIMARY KEY NOT NULL,
    ID_Consulta INT REFERENCES Consulta(ID_Consulta)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Nome_Medico VARCHAR(50) NOT NULL,
    Nome_Exame VARCHAR(20) NOT NULL,
    Qtd_Medicamento INT NOT NULL,
    Medicamento VARCHAR(20) NOT NULL
);

CREATE INDEX idx_receita_medica_id_consulta ON Receita_Medica(ID_Consulta);

CREATE TABLE Medico_Avaliacao
(
    Cod_CRM CHAR(9) REFERENCES Medico(Cod_CRM)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Cod_Procedimento INT REFERENCES Avaliacao_Medica(Cod_Procedimento)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    PRIMARY KEY (Cod_CRM, Cod_Procedimento)
);

CREATE TABLE Quarto
(
    Numero INT PRIMARY KEY NOT NULL,
    Quantidade INT NOT NULL,
    Tipo VARCHAR(20) NOT NULL
);

CREATE TABLE Leito
(
    Numero INT PRIMARY KEY NOT NULL IDENTITY(1000,10),
    Numero_Quarto INT REFERENCES Quarto(Numero)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Tipo VARCHAR(20) NOT NULL,
    Quantidade INT NOT NULL
);

CREATE TABLE Internacao
(
    Laudo_Autorizacao VARCHAR(200) PRIMARY KEY NOT NULL,
    Numero_Leito INT REFERENCES Leito(Numero)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Cod_Procedimento INT REFERENCES Avaliacao_Medica(Cod_Procedimento)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Tipo VARCHAR(20) NOT NULL,
    Procedimento VARCHAR(20) NOT NULL,
    Data_Entrada DATE NOT NULL,
    Data_Prev_Alta DATE NOT NULL,
    Data_Alta DATE,
    Medico_Responsavel VARCHAR(50) NOT NULL,
    CONSTRAINT chk_datas_internacao CHECK (Data_Alta >= Data_Entrada)
);

CREATE TABLE Enfermeiro
(
    Reg_CRE INT PRIMARY KEY NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    CPF CHAR(11) NOT NULL
);

CREATE TABLE Leito_Enfermeiro
(
    Reg_CRE INT REFERENCES Enfermeiro(Reg_CRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    Numero_Leito INT REFERENCES Leito(Numero)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    PRIMARY KEY (Reg_CRE, Numero_Leito)
);

INSERT INTO Paciente
(
    CPF,
    Nome,
    Telefone,
    Email,
    Logradouro,
    Numero,
    Complemento,
    CEP,
    Bairro,
    Cidade,
    Estado
)
VALUES 
('13895345231', 'João Cardoso','(11)93465-2145','JaoCar@gmail.com', 'Avenida Brasil', '123','apt.507','54430-143','Moema','São Paulo', 'SP'),
('23475620912','Maria Silva','(21)92468-2045','MariS@gmail.com', 'Rua Benito Juarez', '183','apt.107','57400-123','Centro','Itaguaí', 'RJ'),
('18308419462','Ana Souza','(31)92018-2785','Aninh23@gmail.com', 'Rua Orleans', '497','apt.208','23780-430','Contagem','Belo Horizonte','MG');

SELECT * FROM Paciente;

INSERT INTO Convenio
(Nome, CNPJ, Tempo_Carencia)
VALUES
('Bradesco Seguros', '33.055.146/0001-93', '60 Dias'),
('Unimed', '48.090.146/0001-00', '60 Dias'),
('Amil', '29.309.127/0122-66', '30 Dias');

SELECT * FROM Convenio;

INSERT INTO Avaliacao_Medica
(Cod_Procedimento, Exame)
VALUES 
(1001, 'Hemograma'),
(1002, 'Cardiograma'),
(1003, 'Ultrasom');

SELECT * FROM Avaliacao_Medica;

INSERT INTO Medico
(Cod_CRM, Especialidade, Nome, Telefone, CPF)
VALUES 
('294010256', 'Clínico Geral', 'Júlia Rosa', '(81)9234-1234', '13423442612'),
('294015259', 'Clínico Geral', 'Henrique Torres','(81)9294-1214', '11426447622');

SELECT * FROM Medico;

INSERT INTO Consulta 
(ID_Consulta, Cod_CRM, Nome_Medico, CPF_Paciente, Nome_Paciente, Especialidade_Medico, Valor_Consulta, Data_Consulta, Hora_Consulta)
VALUES
(10, '294010256', 'Júlia Rosa', '13895345231', 'João Cardoso', 'Clínico Geral', 400, '2024-09-23', '09:00:00'),
(20, '294015259', 'Henrique Torres', '23475620912', 'Maria Silva', 'Clínico Geral', 600, '2024-09-25', '09:00:00'),
(30, '294015259', 'Henrique Torres', '18308419462', 'Ana Souza', 'Clínico Geral', 500, '2024-09-21', '09:00:00');

INSERT INTO Receita_Medica 
(ID_Receita, ID_Consulta, Nome_Medico, Nome_Exame, Qtd_Medicamento, Medicamento)
VALUES
(1, 10, 'Júlia Rosa', 'Hemograma', 20, 'Paracetamol'),
(2, 20, 'Henrique Torres', 'Cardiograma', 5, 'Novalgina'),
(3, 30, 'Henrique Torres', 'Ultrasom', 1, 'Dorflex');

INSERT INTO Quarto(Numero, Quantidade, Tipo)
VALUES 
(101, 10, 'Genérico'),
(102, 40, 'Genérico'),
(103, 100, 'Genérico'),
(201, 10, 'Genérico'),
(202, 40, 'Genérico'),
(203, 100, 'Genérico');

SELECT a.Exame, m.Nome
FROM Avaliacao_Medica AS a
FULL JOIN Medico AS m ON m.Nome = a.Exame;

WITH PacienteComNumeracao AS (
    SELECT 
        CPF,
        Nome,
        Telefone,
        Email,
        Logradouro,
        Numero,
        Complemento,
        CEP,
        Bairro,
        Cidade,
        Estado,
        ROW_NUMBER() OVER (ORDER BY CPF) AS NumPaciente 
    FROM Paciente
),
ConvenioComNumeracao AS (
    SELECT 
        CNPJ,
        Nome,
        Tempo_Carencia,
        ROW_NUMBER() OVER (ORDER BY CNPJ) AS NumConvenio 
    FROM Convenio
)
SELECT 
    p.CPF,
    p.Nome AS NomeDoPaciente,
    p.Telefone,
    p.Email,
    p.Logradouro,
    p.Numero,
    p.Complemento,
    p.CEP,
    p.Bairro,
    p.Cidade,
    p.Estado,
    c.CNPJ,
    c.Nome AS NomeDoConvenio,
    c.Tempo_Carencia
FROM PacienteComNumeracao p
CROSS JOIN ConvenioComNumeracao c
WHERE p.NumPaciente = c.NumConvenio;

SELECT p.Nome, c.Nome
FROM Paciente AS p
FULL JOIN Convenio AS c ON c.Nome = p.Nome;

GO
CREATE TRIGGER mensagemI
ON Paciente
AFTER INSERT
AS
PRINT 'Registro(s) incluído(s) com sucesso!';
GO
CREATE TRIGGER mensagemU
ON Paciente
AFTER UPDATE
AS
PRINT 'Registro(s) alterado(s) com sucesso!';
GO
CREATE TRIGGER mensagemD
ON Paciente
AFTER DELETE
AS
PRINT 'Registro(s) excluído(s) com sucesso!';
GO
CREATE OR ALTER PROCEDURE Bv_Escrever
@Texto VARCHAR(50)
AS
PRINT @Texto;
GO
EXECUTE Bv_Escrever 'Seja Bem Vindo ao Banco de Dados do Hospital';

SELECT * FROM Consulta;


SELECT SUM(Valor_Consulta) AS "Valor total das consultas", AVG(Valor_Consulta) AS "Média das consultas" FROM Consulta; 
SELECT COUNT(*) AS "Total de pacientes" FROM Consulta;
SELECT MIN(Valor_Consulta) AS "Valor Mínimo" FROM Consulta;
SELECT MAX(Valor_Consulta) AS "Valor Máximo" FROM Consulta;


SELECT 
    c.ID_Consulta,
    c.Data_Consulta,
    CONVERT(VARCHAR(8), c.Hora_Consulta, 108) AS Hora_Consulta,
    c.Valor_Consulta,
    p.CPF AS CPF_Paciente,
    p.Nome AS Nome_Paciente,
    p.Telefone AS Telefone_Paciente,
    p.Email AS Email_Paciente,
    m.Cod_CRM AS CRM_Medico,
    m.Nome AS Nome_Medico,
    m.Especialidade AS Especialidade_Medico,
    m.Telefone AS Telefone_Medico
FROM 
    Consulta c
INNER JOIN 
    Paciente p ON c.CPF_Paciente = p.CPF
INNER JOIN 
    Medico m ON c.Cod_CRM = m.Cod_CRM;


SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.index_column_id AS ColumnPosition
FROM 
    sys.indexes i
INNER JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
INNER JOIN 
    sys.tables t ON i.object_id = t.object_id
WHERE 
    i.is_primary_key = 0 AND i.is_unique_constraint = 0
ORDER BY 
    t.name, i.name, ic.index_column_id;

