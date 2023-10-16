from despysas import app, db # aplicativo e banco de dados
from flask import render_template, redirect, url_for, flash # modulos Flask
from despysas.models import vendas
from despysas.forms import CadastroFormDespesa # formularios para validacao

@app.route('/', methods=['GET', "POST"]) # decorator rota raiz
def page_cadastro_despesa():
    form = CadastroFormDespesa() # consulta informacoes do formulario de cadastro de despesas

    if form.validate_on_submit(): # verificacao das entradas no formulario
        despesa= vendas(
            nome = form.nome.data,
            valor = form.valor.data,
            descricao = form.descricao.data,
            categoria = form.categoria.data
        )
        db.session.add(despesa) # prepara o envio dos dados
        db.session.commit() # envia para o bd
    
    if form.errors != {}: #verificacao de erros
        for err in form.errors.values():
            flash(f"Erro ao cadastrar usuário: {err}", category='danger')
    return render_template("cadastro_despesa.html", form=form) # renderiza o formulario

