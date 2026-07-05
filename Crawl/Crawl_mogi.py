import asyncio
import aiohttp
import aiofiles
import csv
import io
from bs4 import BeautifulSoup

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Referer": "https://mogi.vn/"
}
OUTPUT_FILE = "mogi_final_data_1.csv"

def parse_property_detail(html, url):
    detail_data = {
        "Title": "N/A", "Địa chỉ cụ thể": "N/A", "Giá": "N/A", 
        "Diện tích sử dụng": "N/A", "Diện tích đất": "N/A", 
        "Phòng ngủ": "N/A", "Nhà tắm": "N/A", "Pháp lý": "N/A", 
        "Ngày đăng": "N/A", "Mã BĐS": "N/A", "Link": url
    }
    
    soup = BeautifulSoup(html, 'html.parser')
    
    # 1. Title
    title = soup.find('h1') or soup.select_one('.title h1') or soup.select_one('.p-title h1')
    if title: detail_data['Title'] = title.text.strip()
    
    
    address_elem = soup.select_one('.address') or soup.select_one('.p-address') or soup.select_one('.property-address')
    if address_elem: detail_data['Địa chỉ cụ thể'] = address_elem.text.strip()
    
    
    price = soup.select_one('.price') or soup.select_one('.p-price') or soup.select_one('.property-price')
    if price: detail_data['Giá'] = price.text.strip()

    
    mapping = {
        'diện tích sử dụng': 'Diện tích sử dụng', 'diện tích đất': 'Diện tích đất', 
        'phòng ngủ': 'Phòng ngủ', 'nhà tắm': 'Nhà tắm', 
        'pháp lý': 'Pháp lý', 'ngày đăng': 'Ngày đăng', 'mã bđs': 'Mã BĐS'
    }
    
    for key, field_name in mapping.items():
        label_node = soup.find(string=lambda t: t and t.strip(' :-\n\t').lower() == key)
        if label_node:
            
            parent = label_node.parent
            next_tag = parent.find_next_sibling()
            if next_tag and next_tag.text.strip():
                detail_data[field_name] = next_tag.text.strip()
            
    return detail_data

async def writer_worker(queue):
    """Hàm chuyên dụng để ghi file CSV, tránh lỗi xung đột"""
    async with aiofiles.open(OUTPUT_FILE, mode='a', encoding='utf-8-sig', newline='') as f:
        while True:
            data = await queue.get()
            if data is None: break
            
            
            output = io.StringIO()
            writer = csv.DictWriter(output, fieldnames=data.keys())
            writer.writerow(data)
            await f.write(output.getvalue())
            queue.task_done()

async def fetch_and_parse(session, url, semaphore, queue):
    async with semaphore:
        try:
            async with session.get(url, headers=HEADERS, timeout=15) as response:
                html = await response.text()
                data = parse_property_detail(html, url)
                await queue.put(data)
                print(f" Đã thu thập: {url}")
        except Exception as e:
            print(f"❌ Lỗi {url}: {e}")

async def get_links_from_page(session, page):
    url = f"https://mogi.vn/ho-chi-minh/mua-nha-dat?cp={page}"
    try:
        async with session.get(url, headers=HEADERS, timeout=15) as resp:
            soup = BeautifulSoup(await resp.text(), 'html.parser')
            links = []
            for a in soup.select("a.link-overlay"):
                link = a['href']
                if not link.startswith("http"):
                    link = "https://mogi.vn" + link
                links.append(link)
            return list(set(links))
    except: return []

async def main(start_page, end_page):
    # Ghi header trước
    with open(OUTPUT_FILE, 'w', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["Title", "Địa chỉ cụ thể", "Giá", "Diện tích sử dụng", "Diện tích đất", "Phòng ngủ", "Nhà tắm", "Pháp lý", "Ngày đăng", "Mã BĐS", "Link"])

    queue = asyncio.Queue()
    semaphore = asyncio.Semaphore(5)
    
    # Bắt đầu worker ghi file
    writer_task = asyncio.create_task(writer_worker(queue))
    
    async with aiohttp.ClientSession() as session:
        for page in range(start_page, end_page + 1):
            print(f"\n--- ĐANG QUÉT TRANG {page} ---")
            links = await get_links_from_page(session, page)
            tasks = [fetch_and_parse(session, link, semaphore, queue) for link in links]
            await asyncio.gather(*tasks)
            
    await queue.put(None) 
    await writer_task

if __name__ == "__main__":
    asyncio.run(main(1, 36000)) 