# Docker Eval

## Images

### sqlite.Dockerfile (image name: eval-sqlite)

- From alpine
- Installation de node et yarn pour run l'application
- Installation de sqlite pour le traiter de la db
- Set le Workdir
- Copier le contenu de la racine du projet pour le mettre dans l'image

### Dockerfile (image name: eval)

- From alpine
- Installation de node et yarn pour run l'application
- Set le Workdir
- Copier le contenu de la racine du projet pour le mettre dans l'image
