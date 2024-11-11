#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFER 80
#define MAX_TIME 100

typedef struct{
    int id; // da 1 a 127
    int durata; // da 1 a 10
    int scadenza; // da 1 a 100
    int priority; // 1:min 5:mmax
}Order;

enum ALGO{_EDF = 0, _HPF = 1};


Order *getOrders(FILE *fid, int *elem);

Order *orderOrders(Order *orders, enum ALGO algo, int num);
void order(Order *orders, int num, enum ALGO algo, int (*f)(Order, Order));

int EDF_compare(Order order_1, Order order_2);
int HPF_compare(Order order_1, Order order_2);
char *options(enum ALGO *algo);

void computeOrders(Order *orders, int len);

void printOrders(Order *orders, int len);

int main(int argc, char* argv[])
{
    enum ALGO e_algo;
    e_algo = _EDF;
    char *filename;
    filename = options(&e_algo);

    printf(e_algo == _HPF ? "Usiamo HPF\n" : "Usiamo EDF\n");  
    FILE *fid;
    Order *orders; int ordersNum;

    fid = fopen("/home/alessio/Documents/Architettura/ASSEMBLY/Eleaborato/Ordini/Both.txt", "r");
    if(!fid){printf("Error in file\n");return 1;}

    orders = getOrders(fid, &ordersNum);
    
    orderOrders(orders, e_algo, ordersNum);

    printOrders(orders, ordersNum);
    
    computeOrders(orders, ordersNum);

    free(orders);
    fclose(fid);
    return 0;
}

Order *getOrders(FILE *fid, int *elems){

    char string[BUFFER];
    int buffer = 50;
    int count = 0;

    // fgets(string, BUFFER, fid);
    while (!feof(fid))
    {
        fgets(string, BUFFER, fid);
        count++;
    }


    rewind(fid);
    Order *orders = (Order *)malloc(count*sizeof(Order));
    int index = 0;
    // fgets(string, buffer+50, fid);
    while (index<=count)
    {
        fscanf(fid, "%d,%d,%d,%d", &orders[index].id, &orders[index].durata,
                                &orders[index].scadenza, &orders[index].priority);
        index++;
    }
    
    *elems = count;
    return orders;
}


void computeOrders(Order *orders, int len){

    printf("\n\n[+] Risultati algoritmo:\n");
    int time = 0;
    int penality = 0;
    for (int i = 0; i < len; i++)
    {
        printf("%d:%d\n", orders[i].id, time);
        time += orders[i].durata;
        penality += ((time - orders[i].scadenza) > 0) ? orders[i].priority*(time - orders[i].scadenza) : 0;
    }

    printf("Conclusione: %d\n", time);
    printf("Penality: %d\n", penality);

}

// #include <fcntl.h>   // Necessario per O_WRONLY e le altre opzioni di apertura
// O_WRONLY


Order *orderOrders(Order *orders, enum ALGO algo, int num)
{
    if(algo == _EDF){order(orders, num, algo, EDF_compare);}
    else{order(orders, num, algo, HPF_compare);}


    FILE *fid;
    fid = fopen("ris.txt", "w");
    if(!fid){printf("Error in file open");exit(1);}

    for (int i = 0; i < num; i++)
    {
        fprintf(fid, "%d,%d,%d,%d\n", orders[i].id, orders[i].durata, 
                                    orders[i].scadenza, orders[i].priority);
    }
    fclose(fid);
}


/*
* Order by expiration date
*/
int EDF_compare(Order order_1, Order order_2)
{
    if(order_1.scadenza > order_2.scadenza){return 1;}
    else if((order_1.scadenza == order_2.scadenza) && order_1.priority < order_2.priority){return 2;}
    else{return 0;}
}

/*
* Order by priority
*/
int HPF_compare(Order order_1, Order order_2)
{
    if(order_1.priority < order_2.priority){return 1;}
    else if((order_1.priority == order_2.priority) && (order_1.scadenza >    order_2.scadenza)){return 2;}
    else{return 0;}
}

/**
 * @brief Order orders based on selected algorithm
 * 
 * @param orders 
 * @param num 
 * @param algo 
 * @param compare compare algorithm, EDF or HPF
 */
void order(Order *orders, int num, enum ALGO algo, int (*compare)(Order, Order))
{
    printf("START ORDER\n");
    int flag = 1;
    while(flag != 0)
    {
        flag = 0;
        for (int i = 0; i < num-1; i++)
        {
            int comp = compare(orders[i], orders[i+1]);
            if(comp == 1)
            {
                Order tmp = orders[i+1];
                orders[i+1] = orders[i];
                orders[i] = tmp;
                flag = 1;
            }
            if(comp == 2)
            {
                Order tmp = orders[i+1];
                orders[i+1] = orders[i];
                orders[i] = tmp;
                flag = 1;
            }
        }
    }printf("EDF finished\n");
}

char *options(enum ALGO *algo){
    printf("Select witch order to compute:\n[1]HPF with penality;\n[2]HPF without penality;\n[3]EDF with penality;\n[4]EDF without penality;\n>");

    int num;
    scanf("%d", &num);

    char *file;

    switch (num)
    {
    case 1:
        file = "HPF_penality.txt";
        break;
    case 2:
        file = "HPF_no_penality.txt";
        break;
    case 3:
        file = "EDF_penality.txt";
        break;
    case 4:
        file = "EDF_no_penality.txt/home/alessio/Documents/Architettura/ASSEMBLY/Eleaborato/Ordini/EDF_no_penality.txt";
        break;
    default:
        break;
    }
    
    printf("Select witch algorithm from EDF(number 1) and HPF(number 2):\n>");
    char a = fgetc(stdin);
    a = fgetc(stdin);
    if(a == '1'){*algo = _EDF;}
    else{ *algo = _HPF;}
    printf("---------------------------------\n");
    
    return file;
}


void printOrders(Order *orders, int len)
{
    for (int i = 0; i < len; i++)
    {
        printf("Id: %d, durata: %d, Scadenza: %d, Priority: %d\n", 
            orders[i].id, orders[i].durata, orders[i].scadenza, orders[i].priority);
    }
    
}