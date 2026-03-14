import { useState } from 'react';
import { 
  BarChart3, 
  Link as LinkIcon, 
  Search, 
  Sparkles, 
  Zap, 
  ShieldCheck, 
  ArrowLeft,
  ExternalLink,
  ShoppingBag,
  Loader2
} from 'lucide-react';
import './App.css';

interface ProductResult {
  store: string;
  price: number;
  url: string;
  logo?: string;
}

function App() {
  const [url, setUrl] = useState('');
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<ProductResult[] | null>(null);

  const handleCompare = async () => {
    if (!url) return;
    
    setLoading(true);
    setResults(null);

    try {
      // Chamando a API do backend
      const response = await fetch(`http://localhost:3001/api/compare?url=${encodeURIComponent(url)}`);
      
      if (!response.ok) {
        throw new Error('Erro ao buscar dados do produto');
      }

      const data = await response.json();
      
      if (data.items && data.items.length > 0) {
         setResults(data.items);
      } else {
        alert('Nenhum dado encontrado para esta URL.');
      }
    } catch (error) {
       console.error("Erro na comparação:", error);
       alert('Ocorreu um erro ao comparar. Verifique o link ou se o backend está rodando.');
    } finally {
      setLoading(false);
    }
  };
  const handleBack = () => {
    setResults(null);
    setUrl('');
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(price);
  };

  return (
    <div className="app-container">
      <header className="container header">
        <div className="logo-container" onClick={handleBack} style={{ cursor: 'pointer' }}>
          <div className="logo-icon">
            <BarChart3 size={24} />
          </div>
          Compare
        </div>
        <div className="header-text">
          Compare preços de produtos em segundos
        </div>
      </header>

      <main className="container">
        {!results && !loading ? (
          <section className="hero-section">
            <h1 className="hero-title">
              Encontre o <span>melhor preço</span> para qualquer produto
            </h1>
            <p>
              Cole o link de um produto e descubra onde comprá-lo mais barato.
              Comparamos preços em diversas lojas automaticamente.
            </p>

            <div className="search-container">
              <div className="input-wrapper">
                <LinkIcon className="input-icon" size={20} />
                <input 
                  type="text" 
                  placeholder="Cole o link do produto aqui..." 
                  className="search-input"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleCompare()}
                />
              </div>
              <button 
                className="search-button"
                onClick={handleCompare}
                disabled={!url}
              >
                <Search size={20} />
                Comparar
              </button>
            </div>

            <div className="features-grid">
              <div className="feature-card">
                <div className="feature-icon-container">
                  <Sparkles size={24} />
                </div>
                <h3>Análise Inteligente</h3>
                <p>Identifica características do produto automaticamente</p>
              </div>

              <div className="feature-card">
                <div className="feature-icon-container">
                  <Zap size={24} />
                </div>
                <h3>Busca Rápida</h3>
                <p>Pesquisa em múltiplas lojas em segundos</p>
              </div>

              <div className="feature-card">
                <div className="feature-icon-container">
                  <ShieldCheck size={24} />
                </div>
                <h3>Links Verificados</h3>
                <p>Apenas lojas confiáveis e produtos equivalentes</p>
              </div>
            </div>
          </section>
        ) : loading ? (
          <section className="loading-section">
            <Loader2 className="spinner" size={48} />
            <h2>Analisando produto...</h2>
            <p>Estamos buscando os melhores preços em todas as lojas parceiras.</p>
          </section>
        ) : (
          <section className="results-section">
            <div className="results-header">
              <button className="back-button" onClick={() => setResults(null)}>
                <ArrowLeft size={20} />
                Voltar
              </button>
              <div className="results-title-container">
                <h2>Resultados Encontrados</h2>
                <p>Encontramos {results?.length} ofertas para sua busca.</p>
              </div>
            </div>

            <div className="results-grid">
              {results?.map((item, index) => (
                <div key={index} className={`result-card ${index === 0 ? 'best-price' : ''}`}>
                  {index === 0 && <div className="badge">Melhor Preço</div>}
                  <div className="result-info">
                    <div className="store-info">
                      <div className="store-avatar">
                        <ShoppingBag size={20} />
                      </div>
                      <h3>{item.store}</h3>
                    </div>
                    <div className="price-tag">
                      {formatPrice(item.price)}
                    </div>
                  </div>
                  <a href={item.url} target="_blank" rel="noopener noreferrer" className="view-button">
                    Ver na Loja
                    <ExternalLink size={16} />
                  </a>
                </div>
              ))}
            </div>
          </section>
        )}
      </main>
    </div>
  );
}

export default App;
