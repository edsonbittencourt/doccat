"use strict";

function loadHtml(arquivo, selector, callback) {
    $(selector).empty();
    $(selector).load(arquivo, function() {
        refReplace(selector);
        if (callback) {
            callback();
        }
    });
}

function refReplace(selector) {
    $('ref-biblia').each(function() {
        const replacement = this.innerHTML;
        $(this).replaceWith(replacement);
    });

    $('ref-catecismogrupo').each(function() {
        let name = $(this).attr('name');
        name = name ? name : this.innerText;
        const replacement = $('<a href="?pagina=catecismo&grupo=' + name + '\">').append(this.innerHTML);
        $(this).replaceWith(replacement);
    });

    $('ref-cec').each(function() {
        let name = $(this).attr('name');
        name = name ? name : this.innerText;
        let replacement = $('<a onclick="javascript:Catecismo.referencia(\'' + name + '\');">').append(this.innerHTML);
        if (selector == '#grupo') { // Se o link vier da barra de grupo, colocar na estrutura do texto
            replacement = $('<a onclick="javascript:Catecismo.texto(\'' + name + '\');">').append(this.innerHTML);
        }
        $(this).replaceWith(replacement);
    });
}

$(document).ready(function () {
    // Trata parâmetros na URL
    const paramArray = location.search.replace('?', '').split('&');
    const params = {};
    for (const param of paramArray) {
        const [key, value] = param.split('=');
        params[key] = value;
    }
    if (params.pagina) {
        loadHtml(params.pagina + '.html', '#doccat', function() {
            switch (params.pagina) {
                case 'catecismo':
                    if (params.grupo) {
                        Catecismo.grupo(params.grupo);
                    }
                    break;
                case 'tribos':
                    // Nada
                    break;
                default:
                    break;
            }
        });
    }
});

class Catecismo {
    // "Grupo" da estrutura do catecismo (subestrutura de um trecho)
    static grupo(nome) {
        loadHtml('catecismo/' + nome + '.html', '#grupo');
    }

    // Mostra o texto como referência
    static referencia(nome) {
        loadHtml('catecismo/cic_' + nome + '.html', '#referencia');
    }

    // Mostra o texto dentro da estrutura
    static texto(nome) {
        loadHtml('catecismo/cic_' + nome + '.html', '#texto');
        // TODO "Navegadores". Ordem: prologo -> 1-184 -> credo -> 185...
    }
}
