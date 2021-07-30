Set-Location (Get-Item $MyInvocation.MyCommand.Path).Directory.FullName

Clear-Host

$apiVersion = "v1"

Function GeraAPI($objeto, $pasta) {
    # Remove pasta, se houver
    If (Test-Path $pasta) {
        Remove-Item $pasta -Recurse -Force
    }
    # Cria pasta
    $pasta = New-Item -Path $pasta -ItemType Directory

    # Processa itens
    $keys = $objeto.Keys
    ForEach ($key In $keys) {
        $objetoFilho = $objeto.$key
        $caminhoFilho = "$($pasta.FullName)\$key"
        If ($key.EndsWith('.json')) {
            $objetoFilho | ConvertTo-Json | Out-File $caminhoFilho
        } Else {
            GeraAPI $objetoFilho (New-Item $caminhoFilho)
        }
    }
}

Start-Transcript ("..\log\$((Get-Item $MyInvocation.MyCommand.Path).Name).log") -Force
Try {
    # Inicializa��o
    $api = @{
        "$apiVersion" = @{
            biblia = @{
            }
        }
    }

    Write-Host "Configura��o"
    $config = Get-Content "..\config\config.json" | ConvertFrom-Json

    Write-Host "  biblia"
    Write-Host "    livro"
    $livroIndex = @()
    ForEach ($livro In $config.biblia.livro) {
        $livroIndex += [ordered]@{
			sigla = $livro.sigla
			nomeCurto = $livro.nomeCurto
			nomeLongo = $livro.nomeLongo
        }
    }
    $api.$apiVersion.biblia.livro = @{
        "index.json" = $livroIndex
    }

    Write-Host "B�blias"
    $versaoIndex = @()

    Write-Host "  bibliacatolica.com.br"
    $fonte = "bibliacatolica.com.br"
    $json = Get-Content "..\download\$fonte.json" | ConvertFrom-Json
    ForEach ($biblia In $json) {
        Write-Host "    $($biblia.nome)"
        $versaoIndex += [ordered]@{
            nome = $biblia.nome
            fonte = $fonte
            idioma = $biblia.lang
            url = $biblia.url
        }

        $arqBiblia = "..\download\$fonte.$($biblia.nome).json"
<#
        $jsonBiblia = Get-Content $arqBiblia | ConvertFrom-Json
        ForEach ($grupoProp In ($jsonBiblia.grupos | Get-Member -MemberType NoteProperty)) {
            $grupo = $jsonBiblia.grupos."$($grupoProp.Name)"
            Write-Host "      $($grupo.nome)"
            ForEach ($livroProp In ($grupo.livros | Get-Member -MemberType NoteProperty)) {
                $livro = $grupo.livros."$($livroProp.Name)"
                Write-Host "        $($livro.nome)"
            }
        }
#>
    }

    # B�blias - fim
    $api.$apiVersion.biblia.versao = @{
        "index.json" = $versaoIndex
    }

    # Gera��o dos arquivos da API
    $pasta = Get-Item("..\api")
    GeraAPI $api $pasta
} Finally {
    Stop-Transcript
}
