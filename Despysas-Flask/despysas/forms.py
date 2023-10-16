from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField
from wtforms.validators import Length
    
class CadastroFormDespesa(FlaskForm):
    # Nao necessita validacao maior, devido a nao serem valores unicos
    
    filial = StringField(label="Filial", validators=[Length(max=(50))])
    cidade = StringField(label="Cidade", validators=[Length(max=50)])
    genero = StringField(label="Sexo", validators=[Length(max=9)])
    tipo = StringField(label="Setor do Produto", validators=[Length(max=70)])
    valor = StringField(label="Valor")
    quantidade = StringField(label="Quantidade")
    taxa = StringField(label="Taxa")
    total = StringField(label="Total")
    data = StringField(label="Data")
    hora = StringField(label="Hora")
    pagamento = StringField(label="Pagamento")
    custo = StringField(label="Custo de produçaõ")
    porcentagem = StringField(label="Valor Recebido")
    lucro = StringField(label="Lucro")
    avaliacao = StringField(label="Avaliação")
    submit = SubmitField(label="Cadastrar")