<?php
phpinfo();
die();
$host = 'localhost';
$port = '3050';
$database = 'path\to\database.fdb';
$username = 'SYSDBA';
$password = 'masterkey';

try {
    $dsn = "firebird:dbname=$host/$port:$database;charset=ISO8859_1";
    $dbh = new PDO($dsn, $username, $password);
    $dbh->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "SELECT * FROM YOUR_TABLE_NAME";
    $stmt = $dbh->query($sql);

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    print_r($results);
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
