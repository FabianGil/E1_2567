** PUNTO 1 

** Inicialmente importamos la base de datos 1 que esta en formato xls a stata
import excel "Base1(4) (1).xls", sheet("base1") firstrow

** Y la guardamos en formato dta con el nombre "base completa agosto 3" . Esta será nuestra base definitiva 
save "base completa agosto 3.dta"
clear

** Luego importamos la base 2, que esta en formato csv, a stata
import delimited "Base2 (1).csv"

** Y la guardamos en formato dta con el nombre "Base 2 pacientes adicionales", para poder añadirla a la "base completa agosto3".
save "base 2 pacientes adicionale.dta"

** Procedemos a abrir la "base completa" que quedara in memory, y luego le añadimos los pacientes adicionales que estan en la "base 2" que esta in disk.
use "base completa agosto 3.dta"
append using "base 2 pacientes adicionale.dta"

** A esta base le añadimos la información que proviene de la base 3, emparejando por var1 (que corresponde l la identificación)
merge 1:1 var1 using "Base3.dta" 

**PUNTOS 2 y 3

** A continuación cambiamos los nombres de las variables, asignamos los rotulos a cada variable y asignamos los rotulos de las variables categoricas a las 9 variables de la nueva base, segun el libro de codigos proporcionado  
label variable var1 "Identificacion del paciente "
rename var1 ID
label variable var2 "sexo del paciente "
rename var2 sexo
label define sexo 0 "Mujer" 1 "Hombre ", replace
label variable var3 "tipo de dolor toraxico"
rename var3 dolor
label define tipodolor 1 "Angina tipica " 2 "Angina atipica" 3 "Dolor no anginoso" 4 "Asintomatico",replace
label variable var4 "Presión arterial sistólica"
rename var4 TAS
label variable var5 "Colesterol total"
rename var5 CT
label variable var6 "Resultados del ECG en reposo "
rename var6 EKG
label define ekg 0 "normal" 1 "Anormalidades de la T o ST " 2 "Probable o definitiva hipertrofia ventricular izquierda ",replace
label variable var7 "Fecha de nacimiento "
rename var7 fechanac
label variable var8 "Diagnostico de enfermedad cardiaca ( enfermedad angiografica)"
rename var8 Diagnostico
label define angio 0 "<50% de obstruccion del diametro" 1 ">50% de obstruccion del diametro",replace
label variable var9 "fecha de la arteriografia coronaria "
rename var9 fechaart

** Finalmente borramos la variable "merge" creada por stata
. drop _merge

** PUNTO 4

* Identificamos los datos incluidos en la variable TAS 
tab TAS

**Dado que en la variable TAS se identifican datos no numericos, los remplazamos con . para simbolizar datos perdidos 
replace TAS = "." in 223
replace TAS = "." in 299
replace TAS = "." in 300

** Con todos los datos numéricos ya podemos comvertir la variable TAS en numerica, asignandole un nuevo nombre "TAS2"
destring TAS, generate(TAS2)

** Procedemos a categorizar la variable de acuerdo a las categorias descritas en la referencia 
egen float TAS3 = cut(TAS2), at(0 90 120 140 160 180 300) icodes

** Y verificamos que la categoria es correcta aplicando ademas las etiquetas de la nueva variable 
tab TAS3
label define tasrecat 0 "Hipotension" 1 "deseada" 2 "prehipertension" 3 "hipertension 1" 4 "hipertension2",replace

 ** PUNTO 5
 
 ** Para generar la edad al momento de la arteriografia hacemos 2 pasos: 
 * Primero convertimos las fechas proporcionadas (fecha de nacimiento y fecha de arteriografia) en el formato de stata, que hace un conteo de los dias con relacion a una fecha especifica.
 * Se debe tener en cuenta que la fecha de nacimiento venia en formato mes, dia año (MDY) y la fecha de arteriografia en formato dia, mes año (DMY)
 gen fechn2 = date( fechanac ,"MDY")
 gen fechart2 = date( fechaart ,"DMY")
 
 ** Luego restamos a la variable fechaart2 la variable fechan2 obteniendo el numero de dias entre ambas fehcas 
 gen edaddias = fechart2- fechn2
 
 *Por último convertimos esa variable en la edad en años y verificamos que la variable obtenida ofrezca resultados lógicos 
 gen edadaños = edaddias/365.25
 sum edadaños
 
 **PUNTO 6
 
 ** Para describir la variable sexo podemos usar una tabla de frecuencia
 tab sexo
 
 *Para describir la edad en años utilizamos estadisticos acordes con variable continua. Podemos además describir la edad al interior de cada subgrupo (en este caso sexo)
 sum edadaños,d
 by sexo, sort : summarize edadaños, detail
 
 * Evaluando el coeficiente de simetria e incluso una prueba estadistica para evaluar normalidad (Shaphiro wilk) encontramos que la muestra no se distribuye normalmente.
 swilk edadaños
 
 * Por tanto se decide presentar la información como mediana y rango intercuartilico, y se presenta con un gráfico de cajas y bigotes 
 
 graph box edadaños , over(sexo)
 
 **PUNTO 7
 
 **Para comparar 2 variables categóricas usamos una tabla de frecuencias de 2 vías . 
tabulate dolor Diagnostico, chi2 row

**Los resultados se presentan en la documento de word anexo
