#define J_DIVERS_MODULE

#include <memory.h>
#include "defs.h"
#include "other.h"

int j_error=FALSE;
int j_error_funktion=0;
int j_error_nummer=0;

/***********************************************************************/

int j_d_fuege_in_liste_ein(void *objekt, J_D_LISTE **erstes, J_D_LISTE **letztes)
{
 J_D_LISTE *neues=NULL;
 neues=(J_D_LISTE *)malloc(sizeof(J_D_LISTE));
 if (neues==NULL)
 {
  j_error_funktion=J_D_FUEGE_IN_LISTE_EIN;
  j_error_nummer=1;
  j_error=J_ERROR_KEIN_SPEICHER;
  return j_error;
 }
 neues->objekt=objekt;
 neues->letztes=*letztes;
 neues->naechstes=NULL;
 if (*erstes==NULL)
  *erstes=neues;
 if (*letztes!=NULL)
  (*letztes)->naechstes=neues;
 *letztes=neues;
 j_error_funktion=J_D_FUEGE_IN_LISTE_EIN;
 j_error_nummer=0;
 j_error=FALSE;
 return j_error;
}

/***********************************************************************/

int j_d_entferne_aus_liste(void *objekt,J_D_LISTE **erstes,J_D_LISTE **letztes)
{
 J_D_LISTE *hilfe=*erstes;
 J_D_LISTE *dieses=NULL;
 while (hilfe!=NULL)
 {
  if (hilfe->objekt==objekt)
  {
   dieses=hilfe;
   break;
  }
  hilfe=hilfe->naechstes;
 }
 if (dieses==NULL)
 {
  j_error_funktion=J_D_ENTFERNE_AUS_LISTE;
  j_error_nummer=1;
  j_error=J_ERROR_NOT_IN_LISTE;
  return j_error;
 }
 if (dieses!=*letztes)
 {
  if (dieses!=*erstes)
  {
   hilfe=dieses->letztes;
   hilfe->naechstes=dieses->naechstes;
   hilfe=dieses->naechstes;
   hilfe->letztes=dieses->letztes;
  }
  else
  {
   *erstes=dieses->naechstes;
   (*erstes)->letztes=NULL;
  }
 }
 else
 {
  if (dieses!=*erstes)
  {
   hilfe=dieses->letztes;
   hilfe->naechstes=NULL;
   *letztes=dieses->letztes;
  }
  else
  {
   *erstes=NULL;
   *letztes=NULL;
  }
 }
 free(dieses);
 j_error_funktion=J_D_ENTFERNE_AUS_LISTE;
 j_error_nummer=0;
 j_error=FALSE;
 return j_error;
}

/***********************************************************************/

int j_d_anzahl_liste(J_D_LISTE *liste)
{
 int i=0;
 while (liste!=NULL)
 {
  i++;
  liste=liste->naechstes;
 }
 j_error_funktion=J_D_ANZAHL_LISTE;
 j_error_nummer=0;
 j_error=FALSE;
 return i;
}

/***********************************************************************/


void **j_d_liste_to_array(J_D_LISTE *liste)
{
 J_D_LISTE *hilfe=liste;
 void **array=NULL;
 int i=0;
 int anzahl=j_d_anzahl_liste(liste);
 if (anzahl==0)
 {
  j_error_funktion=J_D_LISTE_TO_ARRAY;
  j_error_nummer=1;
  j_error=J_ERROR_KEIN_ELEMENT_IN_LISTE;
  return NULL;
 }
 array=(void *)malloc(anzahl*sizeof(void*));
 if (array==NULL)
 {
  j_error_funktion=J_D_LISTE_TO_ARRAY;
  j_error=J_ERROR_KEIN_SPEICHER;
  return NULL;
 }
 while (hilfe!=NULL)
 {
  array[i++]=hilfe->objekt;
  hilfe=hilfe->naechstes;
 }
 j_error_funktion=J_D_LISTE_TO_ARRAY;
 j_error_nummer=0;
 j_error=FALSE;
 return array;
}

/***********************************************************************/

