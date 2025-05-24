from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class Note(BaseModel):
    content: str

# In-memory store
notes: dict[int, str] = {}

@app.get("/")
async def health_check():
    """
    Health check endpoint used by Kubernetes liveness/readiness probes.
    """
    return {"status": "ok"}

@app.post("/notes/{id}", response_model=Note)
async def create_note(id: int, note: Note):
    """
    Create or update a note with the given ID.
    """
    notes[id] = note.content
    return note

@app.get("/notes/{id}", response_model=Note)
async def read_note(id: int):
    """
    Read a note by ID. Returns 404 if not found.
    """
    content = notes.get(id)
    if content is None:
        raise HTTPException(status_code=404, detail="Note not found")
    return Note(content=content)
