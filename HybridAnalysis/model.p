e(sistemaCentrale).
e(areaUtente).
e(sensoriRilevazioniPresenzeA).
e(sensoriRilevazioniPresenzeB).
e(sensoriConsumoEnergetico).
e(portaIngressoA).
e(portaIngressoB).
e(datiRilevazioniPresenze).
e(datiConsumoEnergetico).
e(user).
e(admin).
e(tmpPass).
e(timeValidity).
e(guestAccount).
e(credenzialiAdmin).
e(credenzialiUtente).
e(smartHomeB).
e(smartHomeA).
e(accessPointA).
e(accessPointB).
e(rete).
e(passwordWifi).
e(flussoDatiA).
e(flussoDatiB).
e(firmware).
e(server).
e(firewall).
e(firewallA).
e(firewallB).
e(ids).
e(twoFA).
e(mqttConnectionA).
e(mqttConnectionB).
e(symmetricEncryptionKey).
e(attaccante).


t(accessoNonAutorizzato).
t(furtoCredenziali).
t(furtoDati).
t(phishing).
t(intenzioniMalevoli).
t(accessoFisicoNonAutorizzato).
t(furto).
t(dos).
t(packetInjection).
t(packetSniffing).
t(manInTheMiddle).
t(packetSniffing).
t(ipSpoofing).
t(bruteForceAttack).


%%%%%%%%%%%%%%%%%%%%FURTO PASSWORD ADMIN %%%%%%%%%
control(admin, credenzialiAdmin).
assComp(admin, phishing).
spread(admin, furtoCredenziali).
assVul(credenzialiAdmin, furtoCredenziali).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%FURTO PASSWORD UTENTE %%%%%%%%%%%%%%%%
control(user, credenzialiUtente).
assComp(user, phishing).
spread(user, furtoCredenziali).
assVul(credenzialiUtente, furtoCredenziali).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%PROVA AD ENTRARE NEL SISTEMA CENTRALE UTILIZZANDO PASS ADMIN%%%%%%%
protect(credenzialiAdmin, sistemaCentrale, accessoNonAutorizzato)
protect(twoFA, sistemaCentrale, accessoNonAutorizzato).
contain(sistemaCentrale, credenzialiAdmin).
assVul(sistemaCentrale, accessoNonAutorizzato).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%ENTRA NELL AREA UTENTE%%%%%%%%%%%%%
protect(credenzialiUtente, areaUtente, accessoNonAutorizzato).
contain(areaUtente, credenzialiUtente).
spread(credenzialiUtente, accessoNonAutorizzato).
assVul(areaUtente, accessoNonAutorizzato).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%ACCESSO GUEST RIUSCITO%%%%%%%%%%%%%%%%%%%%%
control(credenzialiUtente, guestAccount).
protect(timeValidity, guestAccount, accessoNonAutorizzato).
assVul(guestAccount, accessoNonAutorizzato).
assComp(timeValidity, intenzioniMalevoli).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%UTILIZZA SHADOW SERVER PER RUBARE CREDENZIALI A RAGGIRARE 2FA%%%%%%%%%%%
%%%modifica perche non va bene cosi, il sistema centrale non risulta compromesso
connect(admin, server, twoFA).
spread(server, intenzioniMalevoli).
assVul(twoFA, intenzioniMalevoli).

connect(sistemaCentrale, accessPointA, server).
protect(firewall, server, dos).
spread(accessPointA, dos).
assVul(server, dos).

control(attaccante, server).
assComp(attaccante, intenzioniMalevoli).
spread(attaccante, ipSpoofing).
assVul(server, ipSpoofing).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%PASSWORD WIFI ADMIN%%%%%%%%%%%%%%%%%%%%%
control(admin, passwordWifi).
spread(admin, accessoNonAutorizzato).
assVul(passwordWifi, furtoCredenziali).

protect(passwordWifi, accessPointA, accessoNonAutorizzato).
control(passwordWifi, accessPointA).
spread(passwordWifi, accessoNonAutorizzato).
assVul(accessPointA, accessoNonAutorizzato).
depend(rete, accessPointA).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%COMPROMISSIONE SMART HOME B WIFI%%%%%%%%%%%%%%%%
protect(passwordWifi, accessPointB, accessoNonAutorizzato).
control(passwordWifi, accessPointB).
assVul(accessPointB, accessoNonAutorizzato).
depend(rete, accessPointB).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%DOS ALLA SMART HOME A%%%%%%%%%%%%%%%%%%%%
connect(user, passwordWifi, rete).
spread(passwordWifi, dos).
protect(firewallA, rete, dos).
assVul(rete, dos).

isContained(firewallA, rete).
spread(rete, intenzioniMalevoli).
assVul(firewallA, intenzioniMalevoli).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5


%%%%%%%%%%%%%%%%%%%%%%%%MAI IN THE MIDDLE%%%%%%%%%%%%%%%%%%%%%%%%
control(firewallA, mqttConnectionA).
spread(firewallA, manInTheMiddle).
assComp(firewallA, intenzioniMalevoli).
assVul(mqttConnectionA, manInTheMiddle).

protect(ids, mqttConnectionB, manInTheMiddle). 
control(firewallB, mqttConnectionB).
spread(firewallB, manInTheMiddle).
assComp(firewallB, intenzioniMalevoli).
assVul(mqttConnectionB, manInTheMiddle).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%PACKET SNIFFING SMART HOME A%%%%%%%%%%%%%%%%%%%% sfruttando man in the middle
%accede ai dati veri e propri filtrati (siccome riesce ad accedere al sistema centrale).
control(sistemaCentrale, datiConsumoEnergetico).
depend(sensoriConsumoEnergetico, sistemaCentrale).
spread(sistemaCentrale, furtoDati).
assVul(datiConsumoEnergetico, furtoDati).

%lavora sul canale di comunicazione
connect(sensoriConsumoEnergetico, mqttConnectionA, flussoDatiA).
depend(datiConsumoEnergetico, flussoDatiA).
spread(mqttConnectionA, packetSniffing).
assVul(flussoDatiA, packetSniffing).
protect(symmetricEncryptionKey, flussoDatiA, packetSniffing).

control(sistemaCentrale, datiRilevazioniPresenze).
assVul(datiRilevazioniPresenze, furtoDati).
depend(datiRilevazioniPresenze, flussoDatiA).

assComp(symmetricEncryptionKey, bruteForceAttack). %assumiamo che l'attaccante scopri la chiave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%PACKET SNIFFING SMART HOME B%%%%%%%%%%%%%%%%
%%%%utilizzando l'accesso fisico in modo da compromettere il sensore solo ad una distanza ravvicinata. (ATTACCANTE NON RIESCE A ENTRARE NEL CANALE).
control(firmware, flussoDatiB).
spread(firmware, packetSniffing).
assVul(flussoDatiB, packetSniffing).
assVul(firmware, intenzioniMalevoli).
depend(sensoriConsumoEnergetico, firmware).
depend(sensoriRilevazioniPresenzeB, firmware).

%%%%compromissione firmware
assComp(firmware, intenzioniMalevoli).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%ACCESSO NON AUTORIZZATO ALL'ABITAZIONE B%%%%%%%%%%%%%%
control(sensoriRilevazioniPresenzeB, portaIngressoB).
spread(sensoriRilevazioniPresenzeB, accessoFisicoNonAutorizzato).
assVul(portaIngressoB, accessoFisicoNonAutorizzato).

protect(portaIngressoB, smartHomeB, furto).
contain(smartHomeB, portaIngressoB).
spread(portaIngressoB, furto).
assVul(smartHomeB, furto).

control(sistemaCentrale, sensoriRilevazioniPresenzeB).
depend(sensoriRilevazioniPresenzeB, sistemaCentrale).
spread(sistemaCentrale, intenzioniMalevoli).
assVul(sensoriRilevazioniPresenzeB, intenzioniMalevoli).
assComp(sistemaCentrale, accessoNonAutorizzato).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%ACCESSO NON AUTORIZZATO ALLA SMART HOME A%%%%%%%%%%%%%%%%
%%%%%sfrutta attacco dos per manomettere i sensori di rilevazione delle presenze
control(sensoriRilevazioniPresenzeA, portaIngressoA).
spread(sensoriRilevazioniPresenzeA, accessoFisicoNonAutorizzato).
assVul(portaIngressoA, accessoFisicoNonAutorizzato).

protect(portaIngressoA, smartHomeA, furto).
contain(smartHomeA, portaIngressoA).
spread(portaIngressoA, furto).
assVul(smartHomeA, furto).

%dos su sensori
connect(user,rete,sensoriRilevazioniPresenzeA).
spread(rete,dos).
assVul(sensoriRilevazioniPresenzeA,dos).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%PACKET INJECTION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
connect(sistemaCentrale, mqttConnectionA, flussoDati).
spread(mqttConnectionA, packetInjection).
assVul(flussoDati, packetInjection).
protect(symmetricEncryptionKey, flussoDati, packetInjection). 

depend(rete, mqttConnectionA).
depend(rete,mqttConnectionB).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%Rule%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
canbeComp(A,T):- 
				assComp(A,T),
				write('\n-> ('),
				write(A), 
				write(') is Assumed Compromised by ('),
				write(T), 
				write(')'). 


canbeMalfun(A):- 
				assMalfun(A),
				write('\n-> ('),
				write(A), 
				write(') is Assumed Mulfuntion') .
				
				
canbeVul(A,T):-  
				assVul(A,T),
				write('\n-> ('),
				write(A), 
				write(') is Assumed Vulnerable to ('),
				write(T), 
				write(')').


%%%%%%%%%%%%%%%%%%%Higt-level%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%Usable
usable(A):- 
			e(A),(\+canbeComp(A,_T), \+canbeMalfun(A)).

%%Protected
protected(A,T):- 
				protect(B,A,T),	usable(B).

%%Safe
notSafe(A,T):- 
			  e(A), t(T),  (\+protected(A,T),   canbeVul(A,T)).

%%Monitored
monitored(A,T):-  
				monitor(B,A,T), usable(B).

%%Replicate
replicated(A):- 
				replica(B,A), usable(B).

%%Checked
checked(A):- 
			check(B,A), usable(B).



%%%%%%%%%%%%%% Derivation Rules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Malfunctioned%%%%%%%%%%%%%%%%%%%%%
canbeMalfun4Comp(A):- 
					canbeComp(A,_T), 
					write('\n-> ('), 
					write(A), 
					write(') can be Mulfuntion because it can be Compromised').

canbeMalfun4Dep(A):- 
					depend(A,B),
					(canbeComp(B,_T); assMalfun(B); canbeMalfun4Dep(B)),
					write('\n-> ('),
					write(A), 
					write(') can be Mulfuntion because depend on ('),
					write(B), 
					write(')').

canbeMalfun(B):- canbeMalfun4Comp(B).
canbeMalfun(B):- canbeMalfun4Dep(B).

%%%%%Vulnerable%%%%%%%%%%%%%%%%%%%%%
canbeVul(A,T):- potentiallyVul(A,T), canbeMalfun4Dep(A).

%%%%%Compromised%%%%%%%%%%%%%%%%%%%%%
canbeComp(A,T2):- 
				control(B,A), 
				canbeComp(B,_T1), 
				spread(B,T2), 
				notSafe(A,T2),
				write('\n-> ('),
				write(A), 
				write(') can be compromises through ('),
				write(B), 
				write(') by ('),
				write(T2),  
				write(')').


canbeComp(A,T2):- 
				connect(C,B,A), 
				canbeComp(B,_T1), 
				spread(B,T2),
				notSafe(A,T2), 
				(canbeComp(C,_T3); \+protected(C,T2)), 
				write('\n-> ('), 
				write(A),
				write(') can be compromises through ('),
				write(B), 
				write(') by ('), 
				write(T2), 
				write(')').

canbeComp(A,T2):- 
				(contain(A,B); isContained(A,B)),
				canbeComp(B,_T1), 
				spread(B,T2), 
				notSafe(A,T2), 
				write('\n-> ('), 
				write(B), 
				write(') compromises ('), 
				write(A), 
				write(') by ('), 
				write(T2),
				write(')').


%%%%%Detectable
canbeDet(A,T):- canbeComp(A,T), monitored(A,T).

%%%%%Restorable
canbeRest(A):- canbeDet(A,_T) , replicated(A).

%%%%Fixed
canbeFix(A):- canbeMalfun(A), checked(A).

%%%%Penso siano necessari per permettere le varie operazioni sopra
%%%%Ad es. control/2 non sarebbe definito se non ci fosse la riga qui sotto

control(a1,b1).
connect(a2,b2,c2).
contain(a3,b3).
isContained(a4,b4).
depend(a5,b5).
protect(a6,b6,c6).
potentiallyVul(a7,b7).
assMalfun(a8).
monitor(a9,b9,c9).
check(a10,b10).
assComp(a11,b11).
assVul(a13,b13).
spread(a14,b14).
replica(a15,b15).
e(a16).
t(a17).

%%%provo a aggiungere voci canbeCompromised(a11,b11). ...
%%%canbeComp(a18,b18).
%%%canbeMalfun(a19).
%%%canbeVul(a20,b20).
%%%canbeDet(a21,b21).
%%%canbeRest(a22).
%%%canbeFix(a23).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%