(* ===== GVL_IO, GVL_Mesures, GVL_Alarmes et PRG_Bornier : texte à coller dans des objets du même nom ===== *)

(* ----- GVL GVL_IO ----- *)
{attribute 'qualified_only'}
VAR_GLOBAL
	AT_201_BRUT AT %IW0 : INT; (* Chlore libre en sortie | brut 0..32767 = 0..2 mg/l | carte AI2 voie 0 *)
	FT_201_BRUT AT %IW1 : INT; (* Débit eau traitée | brut 0..32767 = 0..250 m³/h | carte AI2 voie 1 *)
	DP_201_MAR AT %IX4.0 : BOOL; (* Pompe doseuse en marche | carte DI2 voie 0 *)
	DP_201_DEF AT %IX4.1 : BOOL; (* Pompe doseuse en défaut | carte DI2 voie 1 *)
	LSL_202 AT %IX4.2 : BOOL; (* Niveau bas bidon d'hypochlorite | carte DI2 voie 2 *)
	DP_201_CMD AT %QX2.0 : BOOL; (* Commande pompe doseuse | carte DO2 voie 0 *)
	DP_201_CONS_BRUT AT %QW0 : INT; (* Consigne de dosage | brut 0..32767 = 0..100 % | carte AO2 voie 0 *)
	CL_CONS : REAL; (* Consigne de chlore libre | mg/l | 0..2 *)
END_VAR


(* ----- GVL GVL_Mesures ----- *)
{attribute 'qualified_only'}
VAR_GLOBAL
	AT_201 : REAL; (* Chlore libre en sortie | mg/l | 0..2 | carte AI2 voie 0 *)
	FT_201 : REAL; (* Débit eau traitée | m³/h | 0..250 | carte AI2 voie 1 *)
	DP_201_CONS : REAL; (* Consigne de dosage | % | 0..100 | carte AO2 voie 0 *)
END_VAR


(* ----- GVL GVL_Alarmes ----- *)
{attribute 'qualified_only'}
VAR_GLOBAL
	AT_201_HH : BOOL; (* Chlore libre en sortie : seuil très haut 1.2 mg/l *)
	AT_201_H : BOOL; (* Chlore libre en sortie : seuil haut 0.8 mg/l *)
	AT_201_L : BOOL; (* Chlore libre en sortie : seuil bas 0.2 mg/l *)
	AT_201_LL : BOOL; (* Chlore libre en sortie : seuil très bas 0.1 mg/l *)
END_VAR


(* ----- PROGRAM PRG_Bornier (corps, langage ST) ----- *)
(* Généré par Bornier à partir du projet « Station de pompage SP-12 (exemple) ». Ne pas modifier : régénéré à chaque export. *)
(* Appeler PRG_Bornier à chaque cycle de la tâche principale. *)

(* Mise à l'échelle des entrées analogiques *)
GVL_Mesures.AT_201 := (INT_TO_REAL(GVL_IO.AT_201_BRUT) - 0.0) * ((2.0 - 0.0) / (32767.0 - 0.0)) + 0.0;
GVL_Mesures.FT_201 := (INT_TO_REAL(GVL_IO.FT_201_BRUT) - 0.0) * ((250.0 - 0.0) / (32767.0 - 0.0)) + 0.0;

(* Seuils d'alarme *)
GVL_Alarmes.AT_201_HH := GVL_Mesures.AT_201 >= 1.2 OR (GVL_Alarmes.AT_201_HH AND GVL_Mesures.AT_201 > 1.18);
GVL_Alarmes.AT_201_H := GVL_Mesures.AT_201 >= 0.8 OR (GVL_Alarmes.AT_201_H AND GVL_Mesures.AT_201 > 0.78);
GVL_Alarmes.AT_201_L := GVL_Mesures.AT_201 <= 0.2 OR (GVL_Alarmes.AT_201_L AND GVL_Mesures.AT_201 < 0.22);
GVL_Alarmes.AT_201_LL := GVL_Mesures.AT_201 <= 0.1 OR (GVL_Alarmes.AT_201_LL AND GVL_Mesures.AT_201 < 0.12);

(* Mise à l'échelle des sorties analogiques *)
GVL_IO.DP_201_CONS_BRUT := REAL_TO_INT(LIMIT(0.0, (GVL_Mesures.DP_201_CONS - 0.0) * ((32767.0 - 0.0) / (100.0 - 0.0)) + 0.0, 32767.0));
