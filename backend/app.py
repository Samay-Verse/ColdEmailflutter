from flask import Flask, request, jsonify
from chains import Chain
from portfolio import Portfolio
from utils import clean_text
from langchain_community.document_loaders import WebBaseLoader

app = Flask(__name__)

# Initialize once
chain = Chain()
portfolio = Portfolio()
portfolio.load_portfolio()

@app.route('/generate-email', methods=['POST'])
def generate_email_endpoint():
    data = request.get_json()
    name = data.get('name')
    company = data.get('company')
    role = data.get('role')
    experience = data.get('experience')
    url = data.get('url')  # URL to scrape job page

    # Load and clean job description
    loader = WebBaseLoader([url])
    cleaned = clean_text(loader.load().pop().page_content)

    # Extract jobs from page
    jobs = chain.extract_jobs(cleaned)
    user_info = {
        "name": name,
        "company": company,
        "role": role,
        "experience": experience,
    }

    for job in jobs:
        skills = job.get("skills", [])
        links_meta = portfolio.query_links(skills)
        links = [m["links"] for m in links_meta if "links" in m]
        email = chain.write_mail(job, links, user_info)
        return jsonify({"email": email})

    return jsonify({"email": "No job info found."})

if __name__ == '__main__':
    app.run(debug=True)
