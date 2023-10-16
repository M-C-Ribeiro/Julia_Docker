from despysas import db

class vendas(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(length=30), nullable=False)
    valor = db.Column(db.Float, nullable=False)
    descricao = db.Column(db.String(length=500), nullable=False)
    categoria = db.Column(db.Integer, db.ForeignKey('categorias.id'))

