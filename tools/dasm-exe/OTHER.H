#ifndef J_DIVERS_H
#define J_DIVERS_H

#define MAX( A, B ) ( ( (A) > (B) ) ? (A) : (B) )
#define MIN( A, B ) ( ( (A) < (B) ) ? (A) : (B) )
#define MIN4( A, B, C, D ) ( ( (A) < (B) ) ? (C) : (D) )
#define ABS(a)	((a) >= 0 ? (a) : -(a))



 #define J_ERROR_KEIN_SPEICHER 20
 #define J_ERROR_NOT_IN_LISTE 21
 #define J_ERROR_KEIN_ELEMENT_IN_LISTE 22

 typedef struct {
                  void  *objekt;
                  void  *naechstes;
                  void  *letztes;
         } J_D_LISTE;

 int j_d_fuege_in_liste_ein(void *objekt,J_D_LISTE **erstes,J_D_LISTE **letztes);
 #define J_D_FUEGE_IN_LISTE_EIN 1
 int j_d_entferne_aus_liste(void *objekt,J_D_LISTE **erstes,J_D_LISTE **letztes);
 #define J_D_ENTFERNE_AUS_LISTE 2
 int j_d_anzahl_liste(J_D_LISTE *liste);
 #define J_D_ANZAHL_LISTE 3
 void **j_d_liste_to_array(J_D_LISTE *liste);
 #define J_D_LISTE_TO_ARRAY 4

 extern int j_divers_error;
 extern int j_divers_error_funktion;
 extern int j_divers_error_nummer;

#endif
