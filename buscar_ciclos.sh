#!/bin/sh

vacio=""
ad=`pwd` #directorio actual
#BUSCAMOS Y ALMACENAMOS EN EL VECTOR RSL TODAS LAS RUTAS DONDE SE ENCUENTRAN LOS SOFTLINKS====================================================================================
rutasdeenlaces=`ls -l -R -P | grep ^[.l] | cut -d" " -f1`
RE=( `echo $rutasdeenlaces | tr '\n' ' ' `)
i=0
m=0
ya=0

while [ "${RE[m]}" != "$vacio" ]; do
    w=`echo "${RE[m]}" | cut -d"/" -f1`
    
    if [ "$w" != "." ] && [[ $w == l* ]] ; then
        
        if [ "$ya" -eq "0" ]; then
            contador=`expr $m - 1`
            RSL[i]=`echo ${RE[contador]} | cut -d"." -f2 | cut -d":" -f1` 
            ((i++))
            ((ya++))
        else
            RSL[i]=`echo ${RE[contador]} | cut -d"." -f2 | cut -d":" -f1` 
            ((i++))
            ((ya++))
        fi
    else
        ya=0
    fi
((m++))
done

#BUSCAMOS TODOS LOS CICLOS PRODUCIDOS EN LAS CARPETAS, Y BUSCAMOS LOS INODOS, LOS NOMBRES Y LAS DIRECCIONES DE ESOS SOFTLINKS QE PRODUCEN LOS CICLOS==========================
enlaces=`ls -l -R | grep ^[l] | tr -s " " " " | cut -d" " -f11` #da todos los enlaces a los que apuntan los softlinks de la carpeta actual hasta la última de abajo
E=( `echo $enlaces | tr '\n' ' ' `) #lo almacenamos en el vector E
rutas=`ls -l -R -P | grep ^[.] | tr -s " " " " | cut -d" " -f9 | cut -d"." -f2 | cut -d":" -f1` # da todas las rutas a partir de la ruta inicial hasta la última de abajo
R=( `echo $rutas | tr '\n' ' ' `) #lo almacenamos en el vector R
nombre_link=`ls -l -R | grep ^[l] | tr -s " " " " | cut -d" " -f9` # da el nombre de todos los softlinks de la carpeta actual hasta la última de abajo
echo $nombre_link
N=( `echo $nombre_link | tr '\n' ' ' `) #lo almacenamos en el vector N
i=0
while [ "${E[i]}" != "$vacio" ]; do #mientras el vector de enlaces no esté vacío
    ruta=`echo $ad${RSL[i]}` #almacenamos la ruta de donde apunta un softlink en ruta
    cd $ruta #accedemos a esa ruta
    ra=`echo $ad${E[i]}` #guardamos la dirección de la ruta a la que apunta el softlink en ra
    w=0
    while [ "$ruta" != "$ra" ] && [ "$ruta" != "$ad" ]; do #mientras la dirección en la que estamos no es la misma que la que apunta el softlink
        cd .. #accedemos al directorio padre
        ruta=`pwd` #igualamos ruta a ese directorio
        ((w++)) #incrementamos w
    done
    if [ "$ruta" == "$ra" ]; then #si la dirección en la que estamos es igual a la ruta a la que apunta el softlink
        ruta_ciclica[i]=$ruta #metemos la ruta en la que estamos en ruta_ciclica[i]
        echo ${ruta_ciclica[i]} es una ruta de un softlink cíclico
        x=`echo $ad${RSL[i]}` #guardamos en x la dirección en la que está el softlink
        cd $x #accedemos a la dirección donde está el softlink
        nombre=${N[i]} #guardamos el nombre del softlink en nombre
        IN[i]=`stat ${N[i]} | cut -d" " -f2` #sacamos el número del inodo de ese softlink y lo almacenamos en IN
    else 
        ru=`echo $ad${RSL[i]}`
        echo $ru NO es una ruta de un softlink cíclico
    fi
    ((i++)) #incrementamos i
    cd $ad #volvemos a la carpeta donde está el script
done
#MOSTRAMOS LOS RESULTADOS=====================================================================================================================================================

i=0
echo "INODO            PUNTO           NOMBRE"
while [ "${ruta_ciclica[i]}" != "$vacio" ]; do
    echo "${IN[i]} \t ${E[i]} \t ${N[i]}" $endl
    ((i++))
done

#BORRAR CICLOS================================================================================================================================================================


if [ "$1" == "-rmdel" ]; then
    e=`expr $2 - 1`
    if [ "${E[$e]}" != "$vacio" ]; then
        me=`echo $ad${RSL[$e]}/${N[$e]}`
        rm -i $me
#       echo el elemento:   $ad${RSL[$e]}/${N[$e]}   ha sido borrado
    fi
fi
