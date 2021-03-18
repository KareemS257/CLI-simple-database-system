#!/bin/bash
PS3="Select an option : "

function createDatabase {
echo Enter the name of your Database
read dataBase
mkdir $dataBase
}

function listDatabases {
ls -l | grep ^d | cut -f 12 -d ' '
if [ $? -eq 0 ]
then
echo "No databases currently"
fi 
}

function connectToDatabase {
echo "Enter the name of the database"
read dataBase
typeset exist=0
for dataBases in *
do
if [ -d $dataBase ]
then
exist=1
fi
done
if [ $exist -eq 1 ]
then
cd $dataBase
select choice in "1-Create Table" "2-List Tables" "3-Insert into tables" "4-select from table" "5-Delete from table" "6-Showtable" "7-Disconnect from Database"
do
while true
do 
if [ $REPLY = 1 ]
then 
createTable
break 
fi
if [ $REPLY = 2 ]
then
ls | awk '!/meta/'
break
fi
if [ $REPLY = 3 ]
then
insertIntoTable
break
fi
if [ $REPLY = 4 ]
then
selectFromTable
break
fi
if [ $REPLY = 5 ]
then
deleteFromTable
break 
fi
if [ $REPLY = 6 ]
then
showTable
break 
fi
if [ $REPLY = 7 ]
then
cd ..
Main
break
fi
done
done
else
echo "No such data base"
fi
}

function dropDatabase {
echo "Enter the name of the database you wish to delete"
typeset exist=0
read dataBase
for dataBases in *
do
if [ -d $dataBase ]
then
let exist=1
fi
done
if [ $exist -eq 1 ]
then
echo "You are about to delete the whole database, are you sure?[y/n] "
read answer
if [ $answer = y -o $answer = Y ]
then
rm -r $dataBase 
elif [ $answer = n -o $answer = N ]
then
dropDatabase
fi
else
echo "No such database"
fi
}

function createTable {
echo "Enter the table's name"
read tableName
touch $tableName.csv
touch $tableName'_meta'.csv
echo Enter columns
read -a columns
i=0
col=""
while [ $i -lt ${#columns[@]} ]
do
col=${columns[$i]};
echo -n  $col,
let i=$i+1
done > $tableName.csv
echo "Table Name","Number of columns","Name of columns" > $tableName'_meta'.csv
echo $tableName,${#columns[@]},${columns[0]} >> $tableName'_meta'.csv
let i=1
while [ $i -lt ${#columns[@]} ]
do
col=${columns[$i]};
echo " "," ",${columns[$i]}
let i=$i+1
done >> $tableName'_meta'.csv
}

function insertIntoTable { 
echo "Enter the name of the table"
read tableName
typeset exist=0
for tablenames in *
do
if [ -f  $tableName.csv ]
then 
let exist=1
fi
done
if [ $exist -eq 1 ]
then
echo "Enter values of the new row"
read -a row
typeset i=0
primary=${row[0]}
awk -F,  '{if($1 == '$primary'){ exit 1;} }' $tableName.csv
if [ $? -eq 0 ]
then
element=""
echo -e "\r" >> $tableName.csv
while [ $i -lt ${#row[@]} ]
do
element=${row[$i]};
echo -n  $element,
let i=$i+1
done >> $tableName.csv
else
echo primary key must be a unique value
fi
else
echo "No such table please re-enter your table name"
insertIntoTable
fi

}

function selectFromTable {
echo  "Enter the name of the table"
read tableName
exist=0
for tablenames in *
do
if [ -f $tableName.csv ]
then
exist=1
else
exist=0
fi
done
if [ $exist -eq 1 ]
then 
echo "Choose your row"
read primaryKey
head -1 $tableName.csv | column -t  -o"|" -s ","
grep ^$primaryKey $tableName.csv | column -t  -o"|" -s ","
else
echo "No such table please re-enter a valid table name"
selectFromTable
fi
}

function deleteFromTable {
echo "Enter the name of the table"
read tableName
exist=0
for tablenames in *
do
if [ -f $tableName.csv ]
then
exist=1
else
exist=0
fi
done
if [ $exist -eq 1 ]
then
echo "Choose your row"
read primaryKey
awk -F, '{if ($1 == '$primaryKey'){exit 1}}' $tableName.csv
if [ $? -eq 1 ]
then
sed -i '/^'$primaryKey'/d' $tableName.csv
else
echo "No such key"
fi
else
echo "No such table please re-enter a valid table name"
deleteFromTable
fi
}

function showTable {
echo  "Enter the name of the table"
read tableName
exist=0
for tablenames in *
do
if [ -f $tableName.csv ]
then
exist=1
else
exist=0
fi
done
if [ $exist -eq 1 ]
then
column -t -s"," -o"|" $tableName.csv
else
echo "No such table please re-enter a valid table name"
showTable
fi
}

function Main {
select choice in "1-Create Database" "2-List Databases" "3-Connect to Database" "4-Drop Database" "5-Exit"
do
while true
do
if [ $REPLY = 1 ]
then
createDatabase
break
fi
if [ $REPLY = 2 ]
then
listDatabases
break
fi
if [ $REPLY = 3 ]
then
connectToDatabase
break
fi
if [ $REPLY = 4 ]
then
dropDatabase
break
fi
if [ $REPLY = 5 ]
then
break 2
fi
done
done
}
Main
