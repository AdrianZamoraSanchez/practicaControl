#!/bin/bash

# ---- Comentario de programa azs1004.sh -----
# Autor: Adrián Zamora Sánchez
# Fecha: 20/05/2023
# Versión: 1.0
# Descipción: compara los ficheros con un formato específico para buscar
#			  sus diferencias y sobre todo sus similitudes

# Función que comapra mediante el comando diff
function compararLineas(){
	file1=$1
	file2=$2

	# Se crea una cabecera con los nombres de los ficheros a analizar
	echo "Analisis de $file1 --- $file2 con el comando diff" >> $fileName

	# Se analizan con diff los ficheros y se guardan en el fichero de destino
	diff -i -c $file1.temp $file2.temp | sed 's/\.temp/.sh/' >> $fileName
}

# Función encargada de analizar las funciones
function analizarFunciones(){
	file1=$1
	file2=$2

	# Busca las variables en el archivo .temp y las guarda en el array funciones1
	funciones1=($(grep -oE 'function [[:alnum:]_]+|^[[:alnum:]_]+\(\)' "${file1}.temp" | sed 's/function //' | sort -u))

	# Busca las variables en el archivo .temp y las guarda en el array funciones2
	funciones2=($(grep -oE 'function [[:alnum:]_]+|^[[:alnum:]_]+\(\)' "${file2}.temp" | sed 's/function //' | sort -u))

	# Busca variables duplicadas en los dos arrays y las guarda en el array duplicados
	duplicados=($(comm -12 <(echo "${funciones1[*]}" | tr ' ' '\n' | sort) <(echo "${funciones2[*]}" | tr ' ' '\n' | sort)))

	# Si no hay variables duplicadas, muestra un mensaje indicándolo
	if [ ${#duplicados[@]} -eq 0 ]; then
		echo "No hay funciones duplicadas entre ${file1}.temp y ${file2}.temp" >> $fileName
	fi

	# Si hay variables duplicadas, muestra un mensaje indicándolo y el número de coincidencias
	if [ ${#duplicados[@]} -ne 0 ]; then
		echo "Las siguientes ${#duplicados[@]} funciones esán duplicadas duplicadas: ${duplicados[@]}" >> $fileName
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
	duplicados=($(comm -12 <(echo "${variables1[*]}" | tr ' ' '\n' | sort) <(echo "${variables2[*]}" | tr ' ' '\n' | sort)))

	# Si no hay variables duplicadas, muestra un mensaje indicándolo
	if [ ${#duplicados[@]} -eq 0 ]; then
		echo "No hay variables duplicadas entre ${file1}.temp y ${file2}.temp" >> $fileName
	fi

	# Si hay variables duplicadas, muestra un mensaje indicándolo y el número de coincidencias
	if [ ${#duplicados[@]} -ne 0 ]; then
		echo "Las siguientes ${#duplicados[@]} variables esán duplicadas duplicadas: ${duplicados[@]}" >> $fileName
	fi
}

# Toma los directorios con nombre [a-z]{3}[0-9]{4}
files=( $(find ./ -type d -exec basename {} \; | grep -wP '[a-z]{3}[0-9]{4}') )

#Si el archivo resultado existe elimina su contenido y si no existe lo crea
fileName=$(basename $PWD)
echo "" > $fileName

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

		# Añade un separador para al final del analisis de estos dos ficheros
		echo -e "#-------------------------#\n" >> $fileName

		# Borra los ficheros temporales
		rm $file1.temp $file2.temp 2> /dev/null
	done
done

# Se quitan las diferencias que añade el comando dif, pues solo queremos ver las coincidencias
cat $fileName | sed '/^\*\*\*/d' | sed '/^\---/d' | sed '/^\!/d' | grep -vE '^\s*(!|\+)' | uniq > $fileName.txt

# Elimina el fichero sin la extensión .txt y con las diferencias del comando diff
rm $fileName
