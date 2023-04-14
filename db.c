/* Check OS */
#ifdef __unix__          

    #define OS_Windows 0
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <ctype.h>

#elif defined(_WIN32) || defined(WIN32)

    #define OS_Windows 1
    #include <windows.h>
    #include <stdio.h>
    #include <tchar.h>
    #define DIV 1048576
    #define WIDTH 7
#endif

/*
Funciones utilizadas para compatibilizar windows y linux bajo los comandos de sistema UNIX y DOS
*/

void clearConsole(){
    if(OS_Windows == 1){
        system("cls");
    }else{
        system("clear");
    }
}

/*
Final de los comandos de compatibilización
*/

int showDB(){
    return 0;
}

int createDB(){
    return 0;
}

int deleteDB(){
    return 0;
}

int connectDB(){
    return 0;
}


int main(){
    int op = 1;

    do{
        printf("Choose what you want to do:\n");
        printf("1 - See all databases\n");
        printf("2 - Create a new database\n");
        printf("3 - Delete a database\n");
        printf("4 - Connect to a database\n");
        printf("0 - Close the menú\n");

        scanf("%d", &op);

        switch(op){
            case 1:
                clearConsole();
                showDB();
                break;
            case 2:
                clearConsole();
                createDB();
                break;
            case 3:
                clearConsole();
                deleteDB();
                break;
            case 4:
                clearConsole();
                connectDB();
                break;
            case 5:
                clearConsole();
                printf("NOT IMPLEMENTED\n");
                break;
            case 0:
                clearConsole();
                printf("Shutting down\n");
                break;
            default:
                clearConsole();
                printf("Error\n");
        }

    }while(op != 0);
}