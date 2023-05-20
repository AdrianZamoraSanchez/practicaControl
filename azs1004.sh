#!/bin/bash

# ---- Comentario de programa azs1004.sh -----
# Autor: Adrián Zamora Sánchez
# Fecha: 21/05/2023
# Versión: 1.0
# Descipción: compara los ficheros con un formato específico para buscar
#			  sus diferencias y sobre todo sus similitudes

# Función que comapra mediante el comando diff
function compararLineas(){
	file1=$1
	file2=$2

	# Se crea una cabecera con los nombres de los ficheros a analizar
	echo "Analisis de $file1 --- $file2 con el comando diff" >> $fileName.txt

	# Se analizan con diff los ficheros y se guardan en el fichero de destino
	diff -i -p $file1.temp $file2.temp | sed 's/\.temp/.sh/' >> $fileName.txt
}

# Función encargada de analizar las funciones
function analizarFunciones(){
	file1=$1
	file2=$2

	# Busca las variables en el archivo .temp y las guarda en el array funciones1
	funciones1=($(grep -oE 'function [[:alnum:]_]+' "${file1}.temp" | sed 's/function //' | sort -u))

	# Busca las variables en el archivo .temp y las guarda en el array funciones2
	funciones2=($(grep -oE 'function [[:alnum:]_]+' "${file2}.temp" | sed 's/function //' | sort -u))

	# Busca variables duplicadas en los dos arrays y las guarda en el array duplicados
	duplicados=($(comm -12 <(echo "${funciones1[*]}" | tr ' ' '\n') <(echo "${funciones2[*]}" | tr ' ' '\n')))

	# Si no hay variables duplicadas, muestra un mensaje indicándolo
	if [ ${#duplicados[@]} -eq 0 ]; then
		echo "No hay funciones duplicadas entre ${file1}.temp y ${file2}.temp" >> $fileName.txt
	fi

	# Si hay variables duplicadas, muestra un mensaje indicándolo y el número de coincidencias
	if [ ${#duplicados[@]} -ne 0 ]; then
		echo "Las siguientes ${#duplicados[@]} funciones esán duplicadas duplicadas: ${duplicados[@]}" >> $fileName.txt
	fi
}

# Función encargada de analizar las variables
function analizarVariables(){
	file1=$1
	file2=$2
	
	# Busca las variables en el archivo .sh y las guarda en el array variables
	variables1=($(grep -o '\$[[:alnum:]_]*' "${file1}.temp" | sed 's/\$//' | sort -u))

	# Busca las variables en el archivo .sh y las guarda en el array "variables"
	variables2=($(grep -o '\$[[:alnum:]_]*' "${file2}.temp" | sed 's/\$//' | sort -u))

	# Busca variables duplicadas en los dos arrays y las guarda en el array duplicados
	duplicados=($(comm -12 <(echo "${variables1[*]}" | tr ' ' '\n') <(echo "${variables2[*]}" | tr ' ' '\n')))

	# Si no hay variables duplicadas, muestra un mensaje indicándolo
	if [ ${#duplicados[@]} -eq 0 ]; then
		echo "No hay variables duplicadas entre ${file1}.temp y ${file2}.temp" >> $fileName.txt
	fi

	# Si hay variables duplicadas, muestra un mensaje indicándolo y el número de coincidencias
	if [ ${#duplicados[@]} -ne 0 ]; then
		echo "Las siguientes ${#duplicados[@]} variables esán duplicadas duplicadas: ${duplicados[@]}" >> $fileName.txt
	fi
}

# Toma los nombres de los directorios con nombre [a-z]{3}[0-9]{4}
files=( $(find ./ -type d -exec basename {} \; | grep -wP '[a-z]{3}[0-9]{4}') )

#Si el archivo resultado existe elimina su contenido y si no existe lo crea
fileName=$(basename $PWD)
echo "" > $fileName.txt

# Bucle para analizar uno por uno los ficheros
for ((i=0;i<${#files[@]}-1;i++)) do
	for ((j=i+1;j<${#files[@]};j++)) do
		# Toma el par de ficheros correspondientes del array de ficheros
		file1=${files[i]}
		file2=${files[j]}

		# Guarda una versión de los ficheros sin comentarios ni tabulaciones (no afectan al script)
		cat ./$file1/"$file1".sh | sed 's/#.*//' | tr -d '\t' | sed '/^\s*$/d' > $file1.temp
		cat ./$file2/"$file2".sh | sed 's/#.*//' | tr -d '\t' | sed '/^\s*$/d' > $file2.temp

		# Llamadas a las funciones que se encargan de analizar las similitudes de los ficheros
		compararLineas $file1 $file2

    	analizarVariables $file1 $file2

		analizarFunciones $file1 $file2

		echo "El fichero $file1.sh tiene `wc -l < "$file1.temp"` lineas" >> $fileName.txt
		echo "El fichero $file2.sh tiene `wc -l < "$file2.temp"` lineas" >> $fileName.txt

		# Añade un separador para al final del analisis de estos dos ficheros
		echo -e "#-------------------------#\n" >> $fileName.txt

		# Borra los ficheros temporales creados previamente
		rm $file1.temp $file2.temp 2> /dev/null
	done
done