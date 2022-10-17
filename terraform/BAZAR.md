
output "url" {
// value = module.docker.url
// value = module.aws.url
// value = var.current_provider == "docker" ? module.docker.url : var.current_provider == "aws" ? module.aws.url : ""
value = "plop"
// value = docker_container.fpm-dev-gateway.labels[1]
}

output "human_readable" {
//value = fileset(path.root, "config/**.yaml")
//value = [for filePath in local.file_set : yamldecode(file(filePath))[0]]
#  flatten(formatlist(
#"Module '%s' installed",
#[for o in module.local[0] : o]
#))
value = "test"
}



# Faire d'un côté les modules, de l'autre l'orchestrateur
# https://github.com/jderusse/docker-gitsplit
# https://github.com/janephp/janephp/blob/next/.github/gitsplit/older/.gitsplit.yml
# https://github.com/janephp/janephp/blob/next/.github/workflows/gitsplit.yml

# Est ce que otut ce bordel devrait p as etre aussi un moduleà part, est ce que chaque sous
# module devrait pas etre un repo à part ? (pas sur)
# git slitter truc pour generer els modules TF via github

# faire plus de scripts qui utilise les output genre
# ssh terraform@$(terraform output -raw public_ip) -i ../tf-cloud-init

# Mettre dans la conf les infos de variables ? Bien définir les trucs qui vont dans les tfvars
# ou le yaml et apres c good !


# Créer un module TF pour locker les versions de modules ! ce serait le vrai tf cpompose de la mort
# + du coup un parser de conf yaml avec des helpers pour aller chercher direct les bonnes values
# ha ben  en faitg si on fait ça c bon https://www.terraform.io/registry/modules/publish#releasing-new-versions
# ha ptet pas, ç les met dans le store mais pas sur quie ça detecte
# ha ben  si enf ait c bpon les versions faut juste publier https://github.com/cloudposse/terraform-null-label

# isnpiuration https://cloudposse.com/

# sur provider docker, forcement traefik

# voir pour utiliser des objets ede validation comme là https://www.hashicorp.com/blog/testing-hashicorp-terraform

# voir pour les TU https://www.hashicorp.com/blog/testing-hashicorp-terraform

# voir ça https://www.terraform.io/internals/machine-readable-ui

# voir aussi pour les graphs c cool et ça peut servir pour le builder

# voir pour les interfaces pas compris la réponse ici https://github.com/hashicorp/terraform/issues/23379

# voir ça pour les bonnes pratiques https://deeeet.com/posts/practices-for-better-terraform-module/

# Archi par provider ou par type de brique, ptet mieux par type de brique en fait

# Mettre les modules distants sur git ? hmm, bonne idée ptet, comme çi localement c pas lourd
# https://www.terraform.io/language/modules/develop/publish

# proposer une structure de dev pas forcement en template ? module as yaml direct dans tf starter en fait



# Créer un projet oss qui override automatiquement les variables de module via ce qui est ajouté dans le yaml
# Bon je sais pas encore comment àa s'ajoute dans un ,prijet tf les trucs comme ça haha
# comme ça ? https://www.terraform.io/plugin/framework


# https://learn.hashicorp.com/tutorials/terraform/provider-use?in=terraform/configuration-language
# pas mal ça, creuser la doc

# ajouter une image" rust, une image go aussoi pour els micro servces et donner des exemples d'utilisation
# https://github.com/awslabs/aws-lambda-rust-runtime


# Sino pre ndre le truc à lm'envers et générer des fichiers teraform en fonction de ce quie st passé dansle yaml, genre avdc une méthode copmpile

# Voir  aussi les api etc pour connecter, ça peut etre cool mais meiux se renseigner els providers c ptet plus adapté

https://github.com/gruntwork-io/terratest