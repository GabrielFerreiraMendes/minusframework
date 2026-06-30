# DLL — C-API

O MinusMigrator também é distribuído como uma DLL com interface C para integração com outras linguagens.

## Funções Exportadas

```c
// Aplica migrações pendentes
int Migrator_Up(const char* conexao, const char* diretorio);

// Reverte migrações
int Migrator_Down(const char* conexao, int steps);

// Lista status das migrações
char* Migrator_Status(const char* conexao);

// Cria novo arquivo de migração
int Migrator_Create(const char* nome);

// Libera string alocada pela DLL
void Migrator_FreeString(char* str);
```

## Exemplo em C#

```csharp
[DllImport("MinusMigrator.dll")]
static extern int Migrator_Up(string conexao, string diretorio);

void AplicarMigracoes()
{
    int result = Migrator_Up("MinhaConexao", "./Migrations");
    if (result == 0)
        Console.WriteLine("Migracoes aplicadas com sucesso");
    else
        Console.WriteLine("Erro ao aplicar migracoes");
}
```

## Exemplo em Python

```python
import ctypes

dll = ctypes.CDLL("MinusMigrator.dll")
dll.Migrator_Up.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
dll.Migrator_Up.restype = ctypes.c_int

result = dll.Migrator_Up(b"MinhaConexao", b"./Migrations")
print("OK" if result == 0 else "Erro")
```

## Códigos de Retorno

| Código | Significado |
|--------|-------------|
| `0` | Sucesso |
| `1` | Conexão não encontrada |
| `2` | Diretório de migrações inválido |
| `3` | Erro ao executar SQL |
