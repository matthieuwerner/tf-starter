ajoute run exemple de ouf qui genere du yaml from un tanbleau tf, c ouf ça dans un yaml du coup
${yamlencode({
"backends": [for addr in ip_addrs : "${addr}:${port}"],
})}

https://www.terraform.io/language/functions/templatefile

s'inspirer des exmeples pour al doc c chanmé


pas sur de l'idée d'avoir tous les modules préchargés c de la merde quand même